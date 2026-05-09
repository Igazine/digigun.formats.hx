package digigun.formats.yaml;

import StringTools;
import digigun.formats.FormatResult;
import digigun.formats.FormatWriter;
import digigun.formats.internal.TextFormatTools;
import digigun.formats.yaml.YamlValue.YamlValueData;

using StringTools;

/**
 * Serializes a `YamlDocument` into deterministic YAML text for the supported subset.
 */
class YamlWriter implements FormatWriter<YamlDocument, String> {
  /**
   * Creates a new YAML writer.
   */
  public function new() {}

  /**
   * Serializes the provided YAML document to text.
   */
  public function write(value:YamlDocument):FormatResult<String> {
    return Success(renderValue(value.root, 0));
  }

  function renderValue(value:YamlValue, indent:Int):String {
    return switch (cast(value, YamlValueData)) {
      case VString(stringValue):
        renderScalar(stringValue);
      case VInt(intValue):
        Std.string(intValue);
      case VFloat(floatValue):
        Std.string(floatValue);
      case VBool(boolValue):
        boolValue ? "true" : "false";
      case VNull:
        "null";
      case VArray(arrayValue):
        renderArray(arrayValue, indent);
      case VObject(objectValue):
        renderObject(objectValue, indent);
    };
  }

  function renderObject(value:YamlObject, indent:Int):String {
    var lines = new Array<String>();
    var prefix = indentation(indent);
    for (property in value.properties) {
      if (isScalar(property.value)) {
        lines.push('${prefix}${property.key}: ${renderValue(property.value, indent)}');
      } else {
        lines.push('${prefix}${property.key}:');
        lines.push(renderValue(property.value, indent + 1));
      }
    }
    return lines.join("\n");
  }

  function renderArray(value:YamlArray, indent:Int):String {
    var lines = new Array<String>();
    var prefix = indentation(indent);
    for (item in value.items) {
      if (isScalar(item)) {
        lines.push('${prefix}- ${renderValue(item, indent)}');
      } else {
        lines.push('${prefix}-');
        lines.push(renderValue(item, indent + 1));
      }
    }
    return lines.join("\n");
  }

  function renderScalar(value:String):String {
    if (value == "" || needsQuotes(value)) {
      return '"${TextFormatTools.escapeDoubleQuoted(value)}"';
    }
    return value;
  }

  function isScalar(value:YamlValue):Bool {
    return switch (cast(value, YamlValueData)) {
      case VString(_) | VInt(_) | VFloat(_) | VBool(_) | VNull:
        true;
      case VArray(_) | VObject(_):
        false;
    };
  }

  function needsQuotes(value:String):Bool {
    if (value.indexOf(":") >= 0 || value.indexOf("#") >= 0 || value.indexOf("\n") >= 0 || value.indexOf("\r") >= 0) {
      return true;
    }

    var trimmed = value.trim();
    if (trimmed != value || value == "" || trimmed == "-" || trimmed == "null" || trimmed == "true" || trimmed == "false" || trimmed == "~") {
      return true;
    }

    var lower = trimmed.toLowerCase();
    if (lower == "null" || lower == "true" || lower == "false") {
      return true;
    }

    if ((trimmed.length >= 2 && trimmed.charAt(0) == "[" && trimmed.charAt(trimmed.length - 1) == "]")
      || (trimmed.length >= 2 && trimmed.charAt(0) == "{" && trimmed.charAt(trimmed.length - 1) == "}")) {
      return true;
    }

    if (~/^[+-]?\d+$/.match(trimmed)) {
      return true;
    }

    if (~/^[+-]?(?:\d+\.\d+|\d+\.|\.\d+)(?:[eE][+-]?\d+)?$/.match(trimmed) || ~/^[+-]?\d+[eE][+-]?\d+$/.match(trimmed)) {
      return true;
    }

    return false;
  }

  function indentation(indent:Int):String {
    var output = new StringBuf();
    for (index in 0...indent) {
      output.add("  ");
    }
    return output.toString();
  }
}
