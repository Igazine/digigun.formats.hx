package digigun.formats.csv;

import digigun.formats.FormatCodec;
import digigun.formats.FormatResult;

/**
 * Convenience codec that combines `CsvReader` and `CsvWriter`.
 */
class CsvCodec implements FormatCodec<String, CsvDocument, String> {
  final reader:CsvReader;
  final writer:CsvWriter;

  /**
   * Creates a new CSV codec, optionally reusing custom reader/writer instances.
   */
  public function new(?reader:CsvReader, ?writer:CsvWriter, ?delimiter:String) {
    this.reader = reader == null ? new CsvReader(delimiter) : reader;
    this.writer = writer == null ? new CsvWriter(delimiter) : writer;
  }

  /**
   * Parses CSV text into a `CsvDocument`.
   */
  public function read(input:String):FormatResult<CsvDocument> {
    return reader.read(input);
  }

  /**
   * Serializes a `CsvDocument` into CSV text.
   */
  public function write(value:CsvDocument):FormatResult<String> {
    return writer.write(value);
  }
}

