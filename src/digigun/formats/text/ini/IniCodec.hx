package digigun.formats.text.ini;

import digigun.formats.FormatCodec;
import digigun.formats.FormatResult;

/**
 * Convenience codec that combines `IniReader` and `IniWriter`.
 */
class IniCodec implements FormatCodec<String, IniDocument, String> {
  final reader:IniReader;
  final writer:IniWriter;

  /**
   * Creates a new INI codec, optionally reusing custom reader/writer instances.
   */
  public function new(?reader:IniReader, ?writer:IniWriter) {
    this.reader = reader == null ? new IniReader() : reader;
    this.writer = writer == null ? new IniWriter() : writer;
  }

  /**
   * Parses INI text into an `IniDocument`.
   */
  public function read(input:String):FormatResult<IniDocument> {
    return reader.read(input);
  }

  /**
   * Serializes an `IniDocument` into INI text.
   */
  public function write(value:IniDocument):FormatResult<String> {
    return writer.write(value);
  }
}
