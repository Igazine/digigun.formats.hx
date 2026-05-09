package digigun.formats.toml;

import digigun.formats.FormatResult;
import digigun.formats.FormatWriter;
import digigun.formats.internal.TextFormatTools;
import digigun.formats.toml.TomlValue.TomlValueData;

/**
 * Serializes a `TomlDocument` into deterministic TOML text for the supported subset.
 */
class TomlWriter implements FormatWriter<TomlDocument, String> {
  /**
   * Creates a new TOML writer.
   */
  public function new() {}

  /**
   * Serializes the provided TOML document to text.
   */
  public function write(value:TomlDocument):FormatResult<String> {
    var lines = new Array<String>();

    appendProperties(lines, value.globalProperties);

    for (tableIndex in 0...value.tables.length) {
      var table = value.tables[tableIndex];

      if (lines.length > 0) {
        lines.push("");
      }

      lines.push('[${table.name}]');
      appendProperties(lines, table.properties);
    }

    return Success(lines.join("\n"));
  }

  function appendProperties(lines:Array<String>, properties:Array<TomlProperty>):Void {
    for (property in properties) {
      lines.push('${property.key} = ${renderValue(property.value)}');
    }
  }

  function renderValue(value:TomlValue):String {
    return switch (cast(value, TomlValueData)) {
      case VString(stringValue):
        renderString(stringValue);
      case VInt(intValue):
        Std.string(intValue);
      case VFloat(floatValue):
        Std.string(floatValue);
      case VBool(boolValue):
        boolValue ? "true" : "false";
      case VArray(values):
        renderArray(values);
      case VObject(objectValue):
        renderObject(objectValue);
    };
  }

  function renderArray(values:Array<TomlValue>):String {
    var rendered = new Array<String>();
    for (value in values) {
      rendered.push(renderValue(value));
    }
    return '[${rendered.join(", ")}]';
  }

  function renderObject(value:TomlObject):String {
    var rendered = new Array<String>();
    for (field in value.fields) {
      rendered.push('${field.key} = ${renderValue(field.value)}');
    }
    return '{ ${rendered.join(", ")} }';
  }

  function renderString(value:String):String {
    return '"${TextFormatTools.escapeDoubleQuoted(value)}"';
  }
}
