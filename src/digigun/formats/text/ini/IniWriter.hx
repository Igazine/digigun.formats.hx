package digigun.formats.text.ini;

import digigun.formats.FormatResult;
import digigun.formats.FormatWriter;
import digigun.formats.internal.TextFormatTools;
import digigun.formats.text.ini.IniValue.IniValueData;

/**
 * Serializes an `IniDocument` into deterministic INI text.
 */
class IniWriter implements FormatWriter<IniDocument, String> {
  /**
   * Creates a new INI writer.
   */
  public function new() {}

  /**
   * Serializes the provided INI document to text.
   */
  public function write(value:IniDocument):FormatResult<String> {
    var lines = new Array<String>();

    appendProperties(lines, value.globalProperties);

    for (sectionIndex in 0...value.sections.length) {
      var section = value.sections[sectionIndex];

      if (lines.length > 0) {
        lines.push("");
      }

      lines.push('[${section.name}]');
      appendProperties(lines, section.properties);
    }

    return Success(lines.join("\n"));
  }

  function appendProperties(lines:Array<String>, properties:Array<IniProperty>):Void {
    for (property in properties) {
      lines.push('${property.key} = ${renderValue(property.value)}');
    }
  }

  function renderValue(value:IniValue):String {
    return switch (cast(value, IniValueData)) {
      case VString(stringValue):
        renderString(stringValue);
      case VInt(intValue):
        Std.string(intValue);
      case VFloat(floatValue):
        Std.string(floatValue);
      case VBool(boolValue):
        boolValue ? "true" : "false";
    };
  }

  function renderString(value:String):String {
    if (value == "") {
      return "\"\"";
    }

    if (SAFE_STRING_PATTERN.match(value) && !looksAmbiguous(value)) {
      return value;
    }

    return '"${TextFormatTools.escapeDoubleQuoted(value)}"';
  }

  static final SAFE_STRING_PATTERN = ~/^[A-Za-z0-9_.\-\/]+$/;
  static final INTEGER_PATTERN = ~/^[+-]?\d+$/;
  static final FLOAT_PATTERN = ~/^[+-]?(?:\d+\.\d+|\d+\.|\.\d+)(?:[eE][+-]?\d+)?$/;
  static final FLOAT_EXP_PATTERN = ~/^[+-]?\d+[eE][+-]?\d+$/;

  function looksAmbiguous(value:String):Bool {
    var lower = value.toLowerCase();
    return lower == "true"
      || lower == "false"
      || INTEGER_PATTERN.match(value)
      || FLOAT_PATTERN.match(value)
      || FLOAT_EXP_PATTERN.match(value);
  }
}
