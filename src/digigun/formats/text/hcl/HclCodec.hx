package digigun.formats.text.hcl;

import digigun.formats.FormatCodec;
import digigun.formats.FormatResult;

/**
 * Convenience codec that combines `HclReader` and `HclWriter`.
 */
class HclCodec implements FormatCodec<String, HclDocument, String> {
  final reader:HclReader;
  final writer:HclWriter;

  /**
   * Creates a new HCL codec, optionally reusing custom reader/writer instances.
   */
  public function new(?reader:HclReader, ?writer:HclWriter) {
    this.reader = reader == null ? new HclReader() : reader;
    this.writer = writer == null ? new HclWriter() : writer;
  }

  /**
   * Parses HCL2 text into an `HclDocument`.
   */
  public function read(input:String):FormatResult<HclDocument> {
    return reader.read(input);
  }

  /**
   * Serializes an `HclDocument` into HCL2 text.
   */
  public function write(value:HclDocument):FormatResult<String> {
    return writer.write(value);
  }
}

