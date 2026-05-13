package digigun.formats.text.yaml;

import digigun.formats.FormatCodec;
import digigun.formats.FormatResult;

/**
 * Convenience codec that combines `YamlReader` and `YamlWriter`.
 */
class YamlCodec implements FormatCodec<String, YamlDocument, String> {
  final reader:YamlReader;
  final writer:YamlWriter;

  /**
   * Creates a new YAML codec, optionally reusing custom reader/writer instances.
   */
  public function new(?reader:YamlReader, ?writer:YamlWriter) {
    this.reader = reader == null ? new YamlReader() : reader;
    this.writer = writer == null ? new YamlWriter() : writer;
  }

  /**
   * Parses YAML text into a `YamlDocument`.
   */
  public function read(input:String):FormatResult<YamlDocument> {
    return reader.read(input);
  }

  /**
   * Serializes a `YamlDocument` into YAML text.
   */
  public function write(value:YamlDocument):FormatResult<String> {
    return writer.write(value);
  }
}

