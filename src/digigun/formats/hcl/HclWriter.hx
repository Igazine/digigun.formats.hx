package digigun.formats.hcl;

import digigun.formats.FormatResult;
import digigun.formats.FormatWriter;
import digigun.formats.hcl.HclValue.HclValueData;
import digigun.formats.internal.TextFormatTools;

/**
 * Serializes an `HclDocument` into deterministic HCL2 text for the supported subset.
 */
class HclWriter implements FormatWriter<HclDocument, String> {
  /**
   * Creates a new HCL writer.
   */
  public function new() {}

  /**
   * Serializes the provided HCL document to text.
   */
  public function write(value:HclDocument):FormatResult<String> {
    return Success(renderBody(value.body, 0));
  }

  function renderBody(body:HclBody, indent:Int):String {
    var lines = new Array<String>();
    var prefix = indentation(indent);

    for (attribute in body.attributes) {
      lines.push('${prefix}${attribute.name} = ${renderValue(attribute.value, indent)}');
    }

    for (block in body.blocks) {
      if (lines.length > 0) {
        lines.push("");
      }
      var labels = new Array<String>();
      for (label in block.labels) {
        labels.push(renderString(label));
      }
      var suffix = labels.length > 0 ? " " + labels.join(" ") : "";
      lines.push('${prefix}${block.type}${suffix} {');
      var renderedBody = renderBody(block.body, indent + 1);
      if (renderedBody != "") {
        lines.push(renderedBody);
      }
      lines.push('${prefix}}');
    }

    return lines.join("\n");
  }

  function renderValue(value:HclValue, indent:Int):String {
    return switch (cast(value, HclValueData)) {
      case VString(stringValue):
        renderStringOrHeredoc(stringValue, indent);
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

  function renderArray(value:HclArray, indent:Int):String {
    var parts = new Array<String>();
    for (item in value.items) {
      parts.push(renderValue(item, indent));
    }
    return '[${parts.join(", ")}]';
  }

  function renderObject(value:HclObject, indent:Int):String {
    if (value.fields.length == 0) {
      return "{}";
    }

    var lines = new Array<String>();
    lines.push("{");
    var prefix = indentation(indent + 1);
    for (field in value.fields) {
      lines.push('${prefix}${field.key} = ${renderValue(field.value, indent + 1)}');
    }
    lines.push('${indentation(indent)}}');
    return lines.join("\n");
  }

  function renderStringOrHeredoc(value:String, indent:Int):String {
    return value.indexOf("\n") >= 0 ? renderHeredoc(value, indent) : renderString(value);
  }

  function renderHeredoc(value:String, indent:Int):String {
    var marker = "EOF";
    while (value.indexOf("\n" + marker + "\n") >= 0 || StringTools.endsWith(value, "\n" + marker)) {
      marker += "_";
    }

    var prefix = indentation(indent);
    return '<<${marker}\n${value}\n${prefix}${marker}';
  }

  function renderString(value:String):String {
    return '"${TextFormatTools.escapeDoubleQuoted(value)}"';
  }

  function indentation(indent:Int):String {
    var output = new StringBuf();
    for (index in 0...indent) {
      output.add("  ");
    }
    return output.toString();
  }
}

