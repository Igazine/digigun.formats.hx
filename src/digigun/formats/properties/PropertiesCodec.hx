package digigun.formats.properties;

import digigun.formats.FormatCodec;
import digigun.formats.FormatResult;

/**
 * Convenience codec that combines `PropertiesReader` and `PropertiesWriter`.
 */
class PropertiesCodec implements FormatCodec<String, PropertiesDocument, String> {
  final reader:PropertiesReader;
  final writer:PropertiesWriter;

  /**
   * Creates a new properties codec, optionally reusing custom reader/writer instances.
   */
  public function new(?reader:PropertiesReader, ?writer:PropertiesWriter) {
    this.reader = reader == null ? new PropertiesReader() : reader;
    this.writer = writer == null ? new PropertiesWriter() : writer;
  }

  /**
   * Parses `.properties` text into a `PropertiesDocument`.
   */
  public function read(input:String):FormatResult<PropertiesDocument> {
    return reader.read(input);
  }

  /**
   * Serializes a `PropertiesDocument` into `.properties` text.
   */
  public function write(value:PropertiesDocument):FormatResult<String> {
    return writer.write(value);
  }
}

