package digigun.formats.image.tiff;

import digigun.formats.FormatCodec;
import digigun.formats.FormatResult;
import digigun.formats.image.TextureData;
import haxe.io.Bytes;

/**
 * Convenience codec that combines `TiffReader` and `TiffWriter`.
 */
class TiffCodec implements FormatCodec<Bytes, TextureData, Bytes> {
  final reader:TiffReader;
  final writer:TiffWriter;

  /**
   * Creates a new TIFF codec, optionally reusing reader/writer instances.
   */
  public function new(?reader:TiffReader, ?writer:TiffWriter) {
    this.reader = reader == null ? new TiffReader() : reader;
    this.writer = writer == null ? new TiffWriter() : writer;
  }

  /**
   * Parses TIFF bytes into texture data.
   */
  public function read(input:Bytes):FormatResult<TextureData> {
    return reader.read(input);
  }

  /**
   * Serializes texture data into TIFF bytes.
   */
  public function write(value:TextureData):FormatResult<Bytes> {
    return writer.write(value);
  }
}
