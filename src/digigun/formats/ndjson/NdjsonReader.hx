package digigun.formats.ndjson;

import digigun.formats.FormatError;
import digigun.formats.FormatErrorCode;
import digigun.formats.FormatLocation;
import digigun.formats.FormatReader;
import digigun.formats.FormatResult;
import digigun.formats.internal.TextFormatTools;
import haxe.Json;

using StringTools;

/**
 * Parses newline-delimited JSON text into an `NdjsonDocument`.
 *
 * JSON parsing is delegated directly to `haxe.Json.parse`.
 */
class NdjsonReader implements FormatReader<String, NdjsonDocument> {
  /**
   * Creates a new NDJSON reader.
   */
  public function new() {}

  /**
   * Parses NDJSON text into a mutable document model.
   */
  public function read(input:String):FormatResult<NdjsonDocument> {
    var normalized = TextFormatTools.normalizeNewlines(input);
    var lines = normalized.split("\n");
    var records = new Array<Dynamic>();

    for (index in 0...lines.length) {
      var lineNumber = index + 1;
      var trimmed = lines[index].trim();
      if (trimmed == "") {
        continue;
      }

      try {
        records.push(Json.parse(trimmed));
      } catch (error:Dynamic) {
        return Failure(new FormatError(
          FormatErrorCode.InvalidStructure,
          'Invalid NDJSON record: ${Std.string(error)}',
          new FormatLocation(lineNumber, 1),
          NdjsonFormat.id
        ));
      }
    }

    return Success(new NdjsonDocument(records));
  }
}

