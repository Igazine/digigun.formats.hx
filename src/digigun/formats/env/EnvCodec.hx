package digigun.formats.env;

import digigun.formats.FormatCodec;
import digigun.formats.FormatResult;

/**
 * Convenience codec that combines `EnvReader` and `EnvWriter`.
 */
class EnvCodec implements FormatCodec<String, EnvDocument, String> {
  final reader:EnvReader;
  final writer:EnvWriter;

  /**
   * Creates a new env codec, optionally reusing custom reader/writer instances.
   */
  public function new(?reader:EnvReader, ?writer:EnvWriter) {
    this.reader = reader == null ? new EnvReader() : reader;
    this.writer = writer == null ? new EnvWriter() : writer;
  }

  /**
   * Parses `.env` text into an `EnvDocument`.
   */
  public function read(input:String):FormatResult<EnvDocument> {
    return reader.read(input);
  }

  /**
   * Serializes an `EnvDocument` into `.env` text.
   */
  public function write(value:EnvDocument):FormatResult<String> {
    return writer.write(value);
  }
}

