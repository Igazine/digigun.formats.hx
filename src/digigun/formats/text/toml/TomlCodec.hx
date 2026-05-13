package digigun.formats.text.toml;

import digigun.formats.FormatCodec;
import digigun.formats.FormatResult;

/**
 * Convenience codec that combines `TomlReader` and `TomlWriter`.
 */
class TomlCodec implements FormatCodec<String, TomlDocument, String> {
  final reader:TomlReader;
  final writer:TomlWriter;

  /**
   * Creates a new TOML codec, optionally reusing custom reader/writer instances.
   */
  public function new(?reader:TomlReader, ?writer:TomlWriter) {
    this.reader = reader == null ? new TomlReader() : reader;
    this.writer = writer == null ? new TomlWriter() : writer;
  }

  /**
   * Parses TOML text into a `TomlDocument`.
   */
  public function read(input:String):FormatResult<TomlDocument> {
    return reader.read(input);
  }

  /**
   * Serializes a `TomlDocument` into TOML text.
   */
  public function write(value:TomlDocument):FormatResult<String> {
    return writer.write(value);
  }
}
