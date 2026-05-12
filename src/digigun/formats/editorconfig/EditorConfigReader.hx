package digigun.formats.editorconfig;

import digigun.formats.FormatError;
import digigun.formats.FormatErrorCode;
import digigun.formats.FormatLocation;
import digigun.formats.FormatReader;
import digigun.formats.FormatResult;
import digigun.formats.ini.IniDocument;
import digigun.formats.ini.IniProperty;
import digigun.formats.ini.IniSection;
import digigun.formats.internal.TextFormatTools;

using StringTools;

/**
 * Parses a supported EditorConfig subset into an `EditorConfigDocument`.
 */
class EditorConfigReader implements FormatReader<String, EditorConfigDocument> {
  /**
   * Creates a new EditorConfig reader.
   */
  public function new() {}

  /**
   * Parses EditorConfig text into the typed document model.
   */
  public function read(input:String):FormatResult<EditorConfigDocument> {
    var normalized = TextFormatTools.normalizeNewlines(input);
    var lines = normalized.split("\n");
    var globalProperties = new Array<IniProperty>();
    var sections = new Array<IniSection>();
    var currentSectionIndex = -1;

    for (index in 0...lines.length) {
      var lineNumber = index + 1;
      var rawLine = lines[index];
      var trimmed = stripComment(rawLine).trim();

      if (trimmed == "") {
        continue;
      }

      if (isSection(trimmed)) {
        var sectionName = trimmed.substr(1, trimmed.length - 2).trim();
        if (sectionName == "") {
          return Failure(error(FormatErrorCode.InvalidStructure, "Section name cannot be empty.", lineNumber, 1));
        }

        sections.push(new IniSection(TextFormatTools.unescape(sectionName)));
        currentSectionIndex = sections.length - 1;
        continue;
      }

      var delimiterIndex = findKeyValueDelimiter(trimmed);
      if (delimiterIndex < 1) {
        return Failure(error(FormatErrorCode.InvalidStructure, "Expected key = value entry.", lineNumber, 1));
      }

      var key = trimmed.substr(0, delimiterIndex).trim().toLowerCase();
      if (key == "") {
        return Failure(error(FormatErrorCode.InvalidStructure, "Property key cannot be empty.", lineNumber, 1));
      }

      var value = TextFormatTools.unescape(trimmed.substr(delimiterIndex + 1).trim());
      var property = new IniProperty(key, value);
      if (currentSectionIndex < 0) {
        globalProperties.push(property);
      } else {
        sections[currentSectionIndex] = sections[currentSectionIndex].withProperty(key, value);
      }
    }

    return Success(new EditorConfigDocument(new IniDocument(globalProperties, sections)));
  }

  function stripComment(line:String):String {
    var output = new StringBuf();
    var escaping = false;
    var whitespaceBeforeComment = false;

    for (index in 0...line.length) {
      var char = line.charAt(index);
      if (escaping) {
        output.add(char);
        escaping = false;
        whitespaceBeforeComment = false;
        continue;
      }

      if (char == "\\") {
        output.add(char);
        escaping = true;
        whitespaceBeforeComment = false;
        continue;
      }

      if ((char == "#" || char == ";") && (output.length == 0 || whitespaceBeforeComment)) {
        return output.toString();
      }

      output.add(char);
      whitespaceBeforeComment = char == " " || char == "\t";
    }

    return output.toString();
  }

  function findKeyValueDelimiter(line:String):Int {
    var escaping = false;
    for (index in 0...line.length) {
      var char = line.charAt(index);
      if (escaping) {
        escaping = false;
        continue;
      }
      if (char == "\\") {
        escaping = true;
        continue;
      }
      if (char == "=") {
        return index;
      }
    }
    return -1;
  }

  inline function isSection(line:String):Bool {
    return line.startsWith("[") && line.endsWith("]");
  }

  inline function error(code:FormatErrorCode, message:String, line:Int, column:Int):FormatError {
    return new FormatError(code, message, new FormatLocation(line, column), EditorConfigFormat.id);
  }
}
