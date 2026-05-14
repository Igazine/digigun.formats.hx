package digigun.formats.text.toml;

import digigun.formats.FormatResult;
import digigun.formats.FormatWriter;
import digigun.formats.internal.TextFormatTools;
import digigun.formats.text.toml.TomlValue.TomlValueData;

using StringTools;

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

      lines.push('[${renderKey(table.name)}]');
      appendProperties(lines, table.properties);
    }

    return Success(lines.join("\n"));
  }

  function appendProperties(lines:Array<String>, properties:Array<TomlProperty>):Void {
    for (property in properties) {
      lines.push('${renderKey(property.key)} = ${renderValue(property.value)}');
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
      rendered.push('${renderKey(field.key)} = ${renderValue(field.value)}');
    }
    return '{ ${rendered.join(", ")} }';
  }

  function renderString(value:String):String {
    return '"${TextFormatTools.escapeDoubleQuoted(value)}"';
  }

  function renderKey(value:String):String {
    var parts = splitKeySegments(value);
    if (parts == null) {
      return renderKeySegment(value);
    }

    var rendered = new Array<String>();
    for (part in parts) {
      rendered.push(renderKeySegment(part));
    }
    return rendered.join(".");
  }

  function splitKeySegments(value:String):Null<Array<String>> {
    var segments = new Array<String>();
    var current = new StringBuf();
    var quote:Null<String> = null;
    var escaping = false;

    for (index in 0...value.length) {
      var char = value.charAt(index);
      if (quote != null) {
        current.add(char);
        if (escaping) {
          escaping = false;
        } else if (char == "\\" && quote == "\"") {
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
        case ".":
          segments.push(current.toString());
          current = new StringBuf();
        default:
          current.add(char);
      }
    }

    if (quote != null) {
      return null;
    }

    segments.push(current.toString());
    return segments;
  }

  function renderKeySegment(value:String):String {
    var trimmed = value.trim();
    if (trimmed == "") {
      return renderString(value);
    }

    if (TextFormatTools.isQuoted(trimmed)) {
      return renderString(TextFormatTools.unescape(trimmed.substr(1, trimmed.length - 2)));
    }

    return isBareKeySegment(trimmed) ? trimmed : renderString(value);
  }

  function isBareKeySegment(value:String):Bool {
    if (value == "") {
      return false;
    }

    for (index in 0...value.length) {
      var char = value.charAt(index);
      var code = char.charCodeAt(0);
      var isAlpha = (code >= "A".code && code <= "Z".code) || (code >= "a".code && code <= "z".code);
      var isDigit = code >= "0".code && code <= "9".code;
      if (!(isAlpha || isDigit || char == "_" || char == "-")) {
        return false;
      }
    }

    return true;
  }
}
