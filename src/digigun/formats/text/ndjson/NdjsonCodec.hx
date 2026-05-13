package digigun.formats.text.ndjson;

import digigun.formats.FormatCodec;
import digigun.formats.FormatResult;

/**
 * Convenience codec that combines `NdjsonReader` and `NdjsonWriter`.
 */
class NdjsonCodec implements FormatCodec<String, NdjsonDocument, String> {
  final reader:NdjsonReader;
  final writer:NdjsonWriter;

  /**
   * Creates a new NDJSON codec, optionally reusing custom reader/writer instances.
   */
  public function new(?reader:NdjsonReader, ?writer:NdjsonWriter) {
    this.reader = reader == null ? new NdjsonReader() : reader;
    this.writer = writer == null ? new NdjsonWriter() : writer;
  }

  /**
   * Parses NDJSON text into an `NdjsonDocument`.
   */
  public function read(input:String):FormatResult<NdjsonDocument> {
    return reader.read(input);
  }

  /**
   * Serializes an `NdjsonDocument` into NDJSON text.
   */
  public function write(value:NdjsonDocument):FormatResult<String> {
    return writer.write(value);
  }
}

