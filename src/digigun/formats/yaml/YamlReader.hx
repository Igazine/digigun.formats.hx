package digigun.formats.yaml;

import digigun.formats.FormatError;
import digigun.formats.FormatErrorCode;
import digigun.formats.FormatLocation;
import digigun.formats.FormatReader;
import digigun.formats.FormatResult;
import digigun.formats.internal.TextFormatTools;

using StringTools;

/**
 * Parses a supported block-style subset of YAML into a `YamlDocument`.
 */
class YamlReader implements FormatReader<String, YamlDocument> {
  static final INTEGER_PATTERN = ~/^[+-]?\d+$/;
  static final FLOAT_PATTERN = ~/^[+-]?(?:\d+\.\d+|\d+\.|\.\d+)(?:[eE][+-]?\d+)?$/;
  static final FLOAT_EXP_PATTERN = ~/^[+-]?\d+[eE][+-]?\d+$/;

  /**
   * Creates a new YAML reader.
   */
  public function new() {}

  /**
   * Parses YAML text into a mutable document model.
   */
  public function read(input:String):FormatResult<YamlDocument> {
    var normalized = TextFormatTools.normalizeNewlines(input);
    var lines = normalized.split("\n");
    var startIndex = nextSignificantLine(lines, 0);

    if (startIndex >= lines.length) {
      return Success(new YamlDocument());
    }

    var indent = lineIndent(lines[startIndex]);
    var parsed = parseBlock(lines, startIndex, indent);
    return switch (parsed) {
      case Failure(error):
        Failure(error);
      case Success(result):
        Success(new YamlDocument(result.value));
    };
  }

  function parseBlock(lines:Array<String>, startIndex:Int, indent:Int):FormatResult<YamlParseResult> {
    var content = stripComment(lines[startIndex]).trim();
    if (content.startsWith("- ")) {
      return parseArray(lines, startIndex, indent);
    }
    return parseObject(lines, startIndex, indent);
  }

  function parseObject(lines:Array<String>, startIndex:Int, indent:Int):FormatResult<YamlParseResult> {
    var value = new YamlObject();
    var index = startIndex;

    while (index < lines.length) {
      var nextIndex = nextSignificantLine(lines, index);
      if (nextIndex >= lines.length) {
        return Success({value: value, nextIndex: lines.length});
      }
      index = nextIndex;

      var currentIndent = lineIndent(lines[index]);
      if (currentIndent < indent) {
        return Success({value: value, nextIndex: index});
      }
      if (currentIndent > indent) {
        return Failure(error("Unexpected indentation in YAML mapping.", index + 1, currentIndent + 1));
      }

      var content = stripComment(lines[index]).trim();
      if (content.startsWith("- ")) {
        return Failure(error("Cannot mix sequence entries into a mapping at the same indentation.", index + 1, currentIndent + 1));
      }

      var separatorIndex = findMappingSeparator(content);
      if (separatorIndex < 1) {
        return Failure(error("Expected key: value entry in YAML mapping.", index + 1, currentIndent + 1));
      }

      var key = content.substr(0, separatorIndex).trim();
      var remainder = content.substr(separatorIndex + 1).trim();
      if (key == "") {
        return Failure(error("YAML mapping key cannot be empty.", index + 1, currentIndent + 1));
      }

      if (remainder == "") {
        var childIndex = nextSignificantLine(lines, index + 1);
        if (childIndex >= lines.length || lineIndent(lines[childIndex]) <= currentIndent) {
          value.setProperty(key, YamlValues.nullValue());
          index++;
          continue;
        }

        var childIndent = lineIndent(lines[childIndex]);
        var childValue = parseBlock(lines, childIndex, childIndent);
        switch (childValue) {
          case Failure(parseError):
            return Failure(parseError);
          case Success(result):
            value.setProperty(key, result.value);
            index = result.nextIndex;
            continue;
        }
      }

      switch (parseScalar(remainder, index + 1, currentIndent + separatorIndex + 2)) {
        case Failure(parseError):
          return Failure(parseError);
        case Success(parsedValue):
          value.setProperty(key, parsedValue);
          index++;
      }
    }

    return Success({value: value, nextIndex: index});
  }

  function parseArray(lines:Array<String>, startIndex:Int, indent:Int):FormatResult<YamlParseResult> {
    var value = new YamlArray();
    var index = startIndex;

    while (index < lines.length) {
      var nextIndex = nextSignificantLine(lines, index);
      if (nextIndex >= lines.length) {
        return Success({value: value, nextIndex: lines.length});
      }
      index = nextIndex;

      var currentIndent = lineIndent(lines[index]);
      if (currentIndent < indent) {
        return Success({value: value, nextIndex: index});
      }
      if (currentIndent > indent) {
        return Failure(error("Unexpected indentation in YAML sequence.", index + 1, currentIndent + 1));
      }

      var content = stripComment(lines[index]).trim();
      if (!content.startsWith("- ")) {
        return Success({value: value, nextIndex: index});
      }

      var remainder = content.substr(2).trim();
      if (remainder == "") {
        var childIndex = nextSignificantLine(lines, index + 1);
        if (childIndex >= lines.length || lineIndent(lines[childIndex]) <= currentIndent) {
          value.add(YamlValues.nullValue());
          index++;
          continue;
        }

        var childIndent = lineIndent(lines[childIndex]);
        var childValue = parseBlock(lines, childIndex, childIndent);
        switch (childValue) {
          case Failure(parseError):
            return Failure(parseError);
          case Success(result):
            value.add(result.value);
            index = result.nextIndex;
            continue;
        }
      }

      switch (parseScalar(remainder, index + 1, currentIndent + 3)) {
        case Failure(parseError):
          return Failure(parseError);
        case Success(parsedValue):
          value.add(parsedValue);
          index++;
      }
    }

    return Success({value: value, nextIndex: index});
  }

  function parseScalar(rawValue:String, line:Int, column:Int):FormatResult<YamlValue> {
    if (TextFormatTools.isQuoted(rawValue)) {
      var quote = rawValue.charAt(0);
      return Success(TextFormatTools.unescape(rawValue.substr(1, rawValue.length - 2), quote));
    }

    var lower = rawValue.toLowerCase();
    if (lower == "true") {
      return Success(true);
    }
    if (lower == "false") {
      return Success(false);
    }
    if (lower == "null" || rawValue == "~") {
      return Success(YamlValues.nullValue());
    }
    if (INTEGER_PATTERN.match(rawValue)) {
      var parsedInt = Std.parseInt(rawValue);
      if (parsedInt == null) {
        return Failure(error('Unable to parse integer "${rawValue}".', line, column));
      }
      return Success(parsedInt);
    }
    if (FLOAT_PATTERN.match(rawValue) || FLOAT_EXP_PATTERN.match(rawValue)) {
      var parsedFloat = Std.parseFloat(rawValue);
      if (Math.isNaN(parsedFloat)) {
        return Failure(error('Unable to parse float "${rawValue}".', line, column));
      }
      return Success(parsedFloat);
    }

    return Success(rawValue);
  }

  function findMappingSeparator(value:String):Int {
    var quote:Null<String> = null;
    var escaping = false;

    for (index in 0...value.length) {
      var char = value.charAt(index);
      if (quote != null) {
        if (escaping) {
          escaping = false;
        } else if (char == "\\") {
          escaping = true;
        } else if (char == quote) {
          quote = null;
        }
        continue;
      }

      switch (char) {
        case "\"", "'":
          quote = char;
        case ":":
          return index;
        default:
      }
    }

    return -1;
  }

  function stripComment(value:String):String {
    var output = new StringBuf();
    var quote:Null<String> = null;
    var escaping = false;

    for (index in 0...value.length) {
      var char = value.charAt(index);
      if (quote != null) {
        output.add(char);
        if (escaping) {
          escaping = false;
        } else if (char == "\\") {
          escaping = true;
        } else if (char == quote) {
          quote = null;
        }
        continue;
      }

      switch (char) {
        case "\"", "'":
          quote = char;
          output.add(char);
        case "#":
          return output.toString();
        default:
          output.add(char);
      }
    }

    return output.toString();
  }

  function nextSignificantLine(lines:Array<String>, startIndex:Int):Int {
    var index = startIndex;
    while (index < lines.length) {
      var content = stripComment(lines[index]).trim();
      if (content != "") {
        return index;
      }
      index++;
    }
    return index;
  }

  function lineIndent(value:String):Int {
    var index = 0;
    while (index < value.length && value.charAt(index) == " ") {
      index++;
    }
    return index;
  }

  inline function error(message:String, line:Int, column:Int):FormatError {
    return new FormatError(FormatErrorCode.InvalidStructure, message, new FormatLocation(line, column), YamlFormat.id);
  }
}

private typedef YamlParseResult = {
  var value:YamlValue;
  var nextIndex:Int;
}

