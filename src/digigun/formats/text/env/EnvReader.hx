package digigun.formats.text.env;

import digigun.formats.FormatError;
import digigun.formats.FormatErrorCode;
import digigun.formats.FormatLocation;
import digigun.formats.FormatReader;
import digigun.formats.FormatResult;
import digigun.formats.internal.TextFormatTools;

using StringTools;

/**
 * Parses `.env` text into an `EnvDocument`.
 */
class EnvReader implements FormatReader<String, EnvDocument> {
  /**
   * Creates a new env reader.
   */
  public function new() {}

  /**
   * Parses `.env` text into a mutable document model.
   */
  public function read(input:String):FormatResult<EnvDocument> {
    var normalized = TextFormatTools.normalizeNewlines(input);
    var entries = new Array<EnvEntry>();
    var lines = normalized.split("\n");

    for (index in 0...lines.length) {
      var lineNumber = index + 1;
      var line = lines[index].trim();

      if (line == "" || line.startsWith("#")) {
        continue;
      }

      var exported = false;
      if (line.startsWith("export ")) {
        exported = true;
        line = line.substr("export ".length).trim();
      }

      var delimiterIndex = line.indexOf("=");
      if (delimiterIndex < 1) {
        return Failure(error("Expected KEY=value entry.", lineNumber, 1));
      }

      var key = line.substr(0, delimiterIndex).trim();
      var rawValue = line.substr(delimiterIndex + 1).trim();
      if (key == "") {
        return Failure(error("Environment variable name cannot be empty.", lineNumber, 1));
      }

      var value = parseValue(rawValue);
      entries.push(new EnvEntry(key, value, exported));
    }

    return Success(new EnvDocument(entries));
  }

  function parseValue(rawValue:String):String {
    if (TextFormatTools.isQuoted(rawValue)) {
      var quote = rawValue.charAt(0);
      return TextFormatTools.unescape(rawValue.substr(1, rawValue.length - 2), quote);
    }

    return rawValue;
  }

  inline function error(message:String, line:Int, column:Int):FormatError {
    return new FormatError(FormatErrorCode.InvalidStructure, message, new FormatLocation(line, column), EnvFormat.id);
  }
}

