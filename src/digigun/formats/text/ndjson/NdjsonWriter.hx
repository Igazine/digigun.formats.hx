package digigun.formats.text.ndjson;

import digigun.formats.FormatResult;
import digigun.formats.FormatWriter;
import haxe.Json;

/**
 * Serializes an `NdjsonDocument` into deterministic NDJSON text.
 *
 * JSON serialization is delegated directly to `haxe.Json.stringify`.
 */
class NdjsonWriter implements FormatWriter<NdjsonDocument, String> {
  /**
   * Creates a new NDJSON writer.
   */
  public function new() {}

  /**
   * Serializes the provided NDJSON document to text.
   */
  public function write(value:NdjsonDocument):FormatResult<String> {
    var lines = new Array<String>();
    for (record in value.records) {
      lines.push(Json.stringify(record));
    }
    return Success(lines.join("\n"));
  }
}

