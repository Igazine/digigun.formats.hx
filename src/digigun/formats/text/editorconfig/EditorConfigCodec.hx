package digigun.formats.text.editorconfig;

import digigun.formats.FormatCodec;
import digigun.formats.FormatResult;

/**
 * Convenience codec that combines `EditorConfigReader` and `EditorConfigWriter`.
 */
class EditorConfigCodec implements FormatCodec<String, EditorConfigDocument, String> {
  final reader:EditorConfigReader;
  final writer:EditorConfigWriter;

  /**
   * Creates a new EditorConfig codec, optionally reusing custom reader/writer instances.
   */
  public function new(?reader:EditorConfigReader, ?writer:EditorConfigWriter) {
    this.reader = reader == null ? new EditorConfigReader() : reader;
    this.writer = writer == null ? new EditorConfigWriter() : writer;
  }

  /**
   * Parses EditorConfig text into an `EditorConfigDocument`.
   */
  public function read(input:String):FormatResult<EditorConfigDocument> {
    return reader.read(input);
  }

  /**
   * Serializes an `EditorConfigDocument` into EditorConfig text.
   */
  public function write(value:EditorConfigDocument):FormatResult<String> {
    return writer.write(value);
  }
}
