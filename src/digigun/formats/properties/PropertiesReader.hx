package digigun.formats.properties;

import digigun.formats.FormatError;
import digigun.formats.FormatErrorCode;
import digigun.formats.FormatLocation;
import digigun.formats.FormatReader;
import digigun.formats.FormatResult;
import digigun.formats.internal.TextFormatTools;

using StringTools;

/**
 * Parses `.properties` text into a `PropertiesDocument`.
 */
class PropertiesReader implements FormatReader<String, PropertiesDocument> {
  /**
   * Creates a new properties reader.
   */
  public function new() {}

  /**
   * Parses `.properties` text into a mutable document model.
   */
  public function read(input:String):FormatResult<PropertiesDocument> {
    var normalized = TextFormatTools.normalizeNewlines(input);
    var entries = new Array<PropertiesEntry>();
    var lines = normalized.split("\n");

    for (index in 0...lines.length) {
      var lineNumber = index + 1;
      var trimmed = lines[index].trim();
      if (trimmed == "" || trimmed.startsWith("#") || trimmed.startsWith("!")) {
        continue;
      }

      var delimiterIndex = findDelimiter(lines[index]);
      if (delimiterIndex < 1) {
        return Failure(error("Expected key=value or key:value entry.", lineNumber, 1));
      }

      var key = lines[index].substr(0, delimiterIndex).trim();
      var value = lines[index].substr(delimiterIndex + 1).trim();
      if (key == "") {
        return Failure(error("Property key cannot be empty.", lineNumber, 1));
      }

      entries.push(new PropertiesEntry(unescape(key), unescape(value)));
    }

    return Success(new PropertiesDocument(entries));
  }

  function findDelimiter(value:String):Int {
    var escaping = false;
    for (index in 0...value.length) {
      var char = value.charAt(index);
      if (escaping) {
        escaping = false;
        continue;
      }
      if (char == "\\") {
        escaping = true;
        continue;
      }
      if (char == "=" || char == ":") {
        return index;
      }
    }
    return -1;
  }

  function unescape(value:String):String {
    return TextFormatTools.unescape(value);
  }

  inline function error(message:String, line:Int, column:Int):FormatError {
    return new FormatError(FormatErrorCode.InvalidStructure, message, new FormatLocation(line, column), PropertiesFormat.id);
  }
}
