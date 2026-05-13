package digigun.formats.text.ini;

import StringTools;
import digigun.formats.FormatError;
import digigun.formats.FormatErrorCode;
import digigun.formats.FormatLocation;
import digigun.formats.FormatReader;
import digigun.formats.FormatResult;
import digigun.formats.internal.TextFormatTools;

using StringTools;

/**
 * Parses a supported subset of INI text into an `IniDocument`.
 */
class IniReader implements FormatReader<String, IniDocument> {
  static final INTEGER_PATTERN = ~/^[+-]?\d+$/;
  static final FLOAT_PATTERN = ~/^[+-]?(?:\d+\.\d+|\d+\.|\.\d+)(?:[eE][+-]?\d+)?$/;
  static final FLOAT_EXP_PATTERN = ~/^[+-]?\d+[eE][+-]?\d+$/;

  /**
   * Creates a new INI reader.
   */
  public function new() {}

  /**
   * Parses INI text into the typed document model.
   */
  public function read(input:String):FormatResult<IniDocument> {
    var normalized = TextFormatTools.normalizeNewlines(input);

    var globalProperties = new Array<IniProperty>();
    var sections = new Array<IniSection>();
    var currentSectionIndex = -1;
    var lines = normalized.split("\n");

    for (index in 0...lines.length) {
      var lineNumber = index + 1;
      var rawLine = lines[index];
      var trimmed = rawLine.trim();

      if (trimmed == "" || isComment(trimmed)) {
        continue;
      }

      if (isSection(trimmed)) {
        var sectionName = trimmed.substr(1, trimmed.length - 2).trim();
        if (sectionName == "") {
          return Failure(error(InvalidStructure, "Section name cannot be empty.", lineNumber, 1));
        }

        sections.push(new IniSection(sectionName));
        currentSectionIndex = sections.length - 1;
        continue;
      }

      var delimiterIndex = trimmed.indexOf("=");
      if (delimiterIndex < 1) {
        return Failure(error(InvalidStructure, "Expected key=value entry.", lineNumber, 1));
      }

      var key = trimmed.substr(0, delimiterIndex).trim();
      var rawValue = trimmed.substr(delimiterIndex + 1).trim();

      if (key == "") {
        return Failure(error(InvalidStructure, "Property key cannot be empty.", lineNumber, 1));
      }

      var parsedValue = parseValue(rawValue, lineNumber);
      switch (parsedValue) {
        case Failure(parseError):
          return Failure(parseError);
        case Success(value):
          var property = new IniProperty(key, value);
          if (currentSectionIndex < 0) {
            globalProperties.push(property);
          } else {
            sections[currentSectionIndex] = sections[currentSectionIndex].withProperty(key, value);
          }
      }
    }

    return Success(new IniDocument(globalProperties, sections));
  }

  function parseValue(rawValue:String, lineNumber:Int):FormatResult<IniValue> {
    if (rawValue == "") {
      return Success("");
    }

    if (TextFormatTools.isQuoted(rawValue)) {
      var quote = rawValue.charAt(0);
      var inner = rawValue.substr(1, rawValue.length - 2);
      return Success(TextFormatTools.unescape(inner, quote));
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
        return Failure(error(InvalidValue, 'Unable to parse integer "${rawValue}".', lineNumber, 1));
      }

      return Success(parsedInt);
    }

    if (FLOAT_PATTERN.match(rawValue) || FLOAT_EXP_PATTERN.match(rawValue)) {
      var parsedFloat = Std.parseFloat(rawValue);
      if (Math.isNaN(parsedFloat)) {
        return Failure(error(InvalidValue, 'Unable to parse float "${rawValue}".', lineNumber, 1));
      }

      return Success(parsedFloat);
    }

    return Success(rawValue);
  }

  function isComment(line:String):Bool {
    return line.startsWith(";") || line.startsWith("#");
  }

  function isSection(line:String):Bool {
    return line.startsWith("[") && line.endsWith("]");
  }

  inline function error(code:FormatErrorCode, message:String, line:Int, column:Int):FormatError {
    return new FormatError(code, message, new FormatLocation(line, column), IniFormat.id);
  }
}
