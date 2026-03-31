package digigun.formats.env;

import StringTools;
import digigun.formats.FormatResult;
import digigun.formats.FormatWriter;
import digigun.formats.internal.TextFormatTools;

/**
 * Serializes an `EnvDocument` into deterministic `.env` text.
 */
class EnvWriter implements FormatWriter<EnvDocument, String> {
  /**
   * Creates a new env writer.
   */
  public function new() {}

  /**
   * Serializes the provided env document to text.
   */
  public function write(value:EnvDocument):FormatResult<String> {
    var lines = new Array<String>();
    for (entry in value.entries) {
      var prefix = entry.exported ? "export " : "";
      lines.push('${prefix}${entry.key}=${renderValue(entry.value)}');
    }
    return Success(lines.join("\n"));
  }

  function renderValue(value:String):String {
    if (value == "" || needsQuotes(value)) {
      return '"' + TextFormatTools.escapeDoubleQuoted(value) + '"';
    }
    return value;
  }

  function needsQuotes(value:String):Bool {
    return value.indexOf(" ") >= 0 || value.indexOf("#") >= 0 || value.indexOf("\"") >= 0 || value.indexOf("\n") >= 0 || value.indexOf("\r") >= 0;
  }
}

