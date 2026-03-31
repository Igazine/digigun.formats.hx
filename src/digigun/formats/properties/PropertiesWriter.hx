package digigun.formats.properties;

import digigun.formats.FormatResult;
import digigun.formats.FormatWriter;
import digigun.formats.internal.TextFormatTools;

/**
 * Serializes a `PropertiesDocument` into deterministic `.properties` text.
 */
class PropertiesWriter implements FormatWriter<PropertiesDocument, String> {
  /**
   * Creates a new properties writer.
   */
  public function new() {}

  /**
   * Serializes the provided `.properties` document to text.
   */
  public function write(value:PropertiesDocument):FormatResult<String> {
    var lines = new Array<String>();
    for (entry in value.entries) {
      lines.push('${escape(entry.key)}=${escape(entry.value)}');
    }
    return Success(lines.join("\n"));
  }

  function escape(value:String):String {
    return TextFormatTools.escapeDoubleQuoted(value);
  }
}

