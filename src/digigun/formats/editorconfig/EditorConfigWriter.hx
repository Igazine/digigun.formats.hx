package digigun.formats.editorconfig;

import StringTools;
import digigun.formats.FormatResult;
import digigun.formats.FormatWriter;
import digigun.formats.ini.IniProperty;
import digigun.formats.ini.IniSection;
import digigun.formats.ini.IniValue;
import digigun.formats.internal.TextFormatTools;

/**
 * Serializes an `EditorConfigDocument` into deterministic EditorConfig text.
 */
class EditorConfigWriter implements FormatWriter<EditorConfigDocument, String> {
  /**
   * Creates a new EditorConfig writer.
   */
  public function new() {}

  /**
   * Serializes the provided EditorConfig document to text.
   */
  public function write(value:EditorConfigDocument):FormatResult<String> {
    var lines = new Array<String>();

    appendRoot(lines, value.globalProperties);
    appendProperties(lines, value.globalProperties, true);

    for (sectionIndex in 0...value.sections.length) {
      var section = value.sections[sectionIndex];

      if (lines.length > 0) {
        lines.push("");
      }

      lines.push('[${escapeSectionName(section.name)}]');
      appendSectionProperties(lines, section);
    }

    return Success(lines.join("\n"));
  }

  function appendRoot(lines:Array<String>, properties:Array<IniProperty>):Void {
    for (property in properties) {
      if (property.key == "root") {
        lines.push('root = ${renderValue(property.value)}');
        return;
      }
    }
  }

  function appendProperties(lines:Array<String>, properties:Array<IniProperty>, skipRoot:Bool):Void {
    for (property in properties) {
      if (skipRoot && property.key == "root") {
        continue;
      }
      lines.push('${escapeKey(property.key)} = ${renderValue(property.value)}');
    }
  }

  function appendSectionProperties(lines:Array<String>, section:IniSection):Void {
    for (property in section.properties) {
      lines.push('${escapeKey(property.key)} = ${renderValue(property.value)}');
    }
  }

  function renderValue(value:IniValue):String {
    return escapeValue(value.asString());
  }

  function escapeKey(value:String):String {
    var escaped = escapeCommon(value);
    escaped = StringTools.replace(escaped, "=", "\\=");
    return escaped.toLowerCase();
  }

  function escapeSectionName(value:String):String {
    var escaped = escapeCommon(value);
    escaped = StringTools.replace(escaped, "[", "\\[");
    escaped = StringTools.replace(escaped, "]", "\\]");
    escaped = StringTools.replace(escaped, "*", "\\*");
    escaped = StringTools.replace(escaped, "?", "\\?");
    escaped = StringTools.replace(escaped, "{", "\\{");
    escaped = StringTools.replace(escaped, "}", "\\}");
    escaped = StringTools.replace(escaped, ",", "\\,");
    return escaped;
  }

  function escapeValue(value:String):String {
    var escaped = escapeCommon(value);
    escaped = StringTools.replace(escaped, "=", "\\=");
    return escaped;
  }

  function escapeCommon(value:String):String {
    var escaped = StringTools.replace(value, "\\", "\\\\");
    escaped = StringTools.replace(escaped, "#", "\\#");
    escaped = StringTools.replace(escaped, ";", "\\;");
    escaped = StringTools.replace(escaped, ":", "\\:");
    escaped = StringTools.replace(escaped, "\n", "\\n");
    escaped = StringTools.replace(escaped, "\r", "\\r");
    escaped = StringTools.replace(escaped, "\t", "\\t");
    return escaped;
  }
}
