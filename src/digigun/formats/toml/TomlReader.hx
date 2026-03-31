package digigun.formats.toml;

import StringTools;
import digigun.formats.FormatError;
import digigun.formats.FormatErrorCode;
import digigun.formats.FormatLocation;
import digigun.formats.FormatReader;
import digigun.formats.FormatResult;
import digigun.formats.internal.TextFormatTools;

using StringTools;

/**
 * Parses a supported subset of TOML text into a `TomlDocument`.
 */
class TomlReader implements FormatReader<String, TomlDocument> {
  static final INTEGER_PATTERN = ~/^[+-]?\d+$/;
  static final FLOAT_PATTERN = ~/^[+-]?(?:\d+\.\d+|\d+\.|\.\d+)(?:[eE][+-]?\d+)?$/;
  static final FLOAT_EXP_PATTERN = ~/^[+-]?\d+[eE][+-]?\d+$/;

  /**
   * Creates a new TOML reader.
   */
  public function new() {}

  /**
   * Parses TOML text into the typed document model.
   */
  public function read(input:String):FormatResult<TomlDocument> {
    var normalized = TextFormatTools.normalizeNewlines(input);

    var globalProperties = new Array<TomlProperty>();
    var tables = new Array<TomlTable>();
    var currentTableIndex = -1;
    var lines = normalized.split("\n");

    for (index in 0...lines.length) {
      var lineNumber = index + 1;
      var trimmed = stripComment(lines[index]).trim();

      if (trimmed == "") {
        continue;
      }

      if (isTable(trimmed)) {
        var tableName = trimmed.substr(1, trimmed.length - 2).trim();
        if (tableName == "") {
          return Failure(error(FormatErrorCode.InvalidStructure, "Table name cannot be empty.", lineNumber, 1));
        }

        tables.push(new TomlTable(tableName));
        currentTableIndex = tables.length - 1;
        continue;
      }

      var delimiterIndex = findKeyValueDelimiter(trimmed);
      if (delimiterIndex < 1) {
        return Failure(error(FormatErrorCode.InvalidStructure, "Expected key = value entry.", lineNumber, 1));
      }

      var key = trimmed.substr(0, delimiterIndex).trim();
      if (key == "") {
        return Failure(error(FormatErrorCode.InvalidStructure, "Property key cannot be empty.", lineNumber, 1));
      }

      var rawValue = trimmed.substr(delimiterIndex + 1).trim();
      var parsedValue = parseValue(rawValue, lineNumber);
      switch (parsedValue) {
        case Failure(parseError):
          return Failure(parseError);
        case Success(value):
          var property = new TomlProperty(key, value);
          if (currentTableIndex < 0) {
            globalProperties.push(property);
          } else {
            tables[currentTableIndex] = tables[currentTableIndex].withProperty(key, value);
          }
      }
    }

    return Success(new TomlDocument(globalProperties, tables));
  }

  function parseValue(rawValue:String, lineNumber:Int):FormatResult<TomlValue> {
    if (rawValue == "") {
      return Failure(error(FormatErrorCode.InvalidValue, "Value cannot be empty.", lineNumber, 1));
    }

    if (TextFormatTools.isQuoted(rawValue)) {
      return Success(TextFormatTools.unescape(rawValue.substr(1, rawValue.length - 2)));
    }

    if (isArray(rawValue)) {
      return parseArray(rawValue, lineNumber);
    }

    var lower = rawValue.toLowerCase();
    if (lower == "true") {
      return Success(true);
    }

    if (lower == "false") {
      return Success(false);
    }

    if (INTEGER_PATTERN.match(rawValue)) {
      var parsedInt = Std.parseInt(rawValue);
      if (parsedInt == null) {
        return Failure(error(FormatErrorCode.InvalidValue, 'Unable to parse integer "${rawValue}".', lineNumber, 1));
      }

      return Success(parsedInt);
    }

    if (FLOAT_PATTERN.match(rawValue) || FLOAT_EXP_PATTERN.match(rawValue)) {
      var parsedFloat = Std.parseFloat(rawValue);
      if (Math.isNaN(parsedFloat)) {
        return Failure(error(FormatErrorCode.InvalidValue, 'Unable to parse float "${rawValue}".', lineNumber, 1));
      }

      return Success(parsedFloat);
    }

    return Failure(error(
      FormatErrorCode.UnsupportedFeature,
      'Unsupported TOML value "${rawValue}". Strings must be quoted and only scalar or array values are supported in this version.',
      lineNumber,
      1
    ));
  }

  function parseArray(rawValue:String, lineNumber:Int):FormatResult<TomlValue> {
    var content = rawValue.substr(1, rawValue.length - 2).trim();
    if (content == "") {
      return Success(([] : Array<TomlValue>));
    }

    var parts = splitArrayItems(content, lineNumber);
    switch (parts) {
      case Failure(errorValue):
        return Failure(errorValue);
      case Success(items):
        var values = new Array<TomlValue>();
        for (item in items) {
          switch (parseValue(item.trim(), lineNumber)) {
            case Failure(parseError):
              return Failure(parseError);
            case Success(value):
              values.push(value);
          }
        }
        return Success(values);
    }
  }

  function splitArrayItems(content:String, lineNumber:Int):FormatResult<Array<String>> {
    var items = new Array<String>();
    var current = new StringBuf();
    var depth = 0;
    var quote:Null<String> = null;
    var escaping = false;

    for (index in 0...content.length) {
      var char = content.charAt(index);

      if (quote != null) {
        current.add(char);
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
          current.add(char);
        case "[":
          depth++;
          current.add(char);
        case "]":
          if (depth == 0) {
            return Failure(error(FormatErrorCode.InvalidStructure, "Unexpected closing bracket in array.", lineNumber, index + 1));
          }
          depth--;
          current.add(char);
        case ",":
          if (depth == 0) {
            items.push(current.toString());
            current = new StringBuf();
          } else {
            current.add(char);
          }
        default:
          current.add(char);
      }
    }

    if (quote != null || depth != 0) {
      return Failure(error(FormatErrorCode.InvalidStructure, "Unterminated TOML array.", lineNumber, 1));
    }

    items.push(current.toString());
    return Success(items);
  }

  function stripComment(line:String):String {
    var output = new StringBuf();
    var quote:Null<String> = null;
    var escaping = false;

    for (index in 0...line.length) {
      var char = line.charAt(index);

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

  function findKeyValueDelimiter(line:String):Int {
    var quote:Null<String> = null;
    var escaping = false;
    var depth = 0;

    for (index in 0...line.length) {
      var char = line.charAt(index);

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
        case "[":
          depth++;
        case "]":
          if (depth > 0) {
            depth--;
          }
        case "=":
          if (depth == 0) {
            return index;
          }
        default:
      }
    }

    return -1;
  }

  function isArray(value:String):Bool {
    return value.length >= 2 && value.charAt(0) == "[" && value.charAt(value.length - 1) == "]";
  }

  function isTable(value:String):Bool {
    return value.length >= 2 && value.charAt(0) == "[" && value.charAt(value.length - 1) == "]";
  }

  inline function error(code:FormatErrorCode, message:String, line:Int, column:Int):FormatError {
    return new FormatError(code, message, new FormatLocation(line, column), TomlFormat.id);
  }
}
