package digigun.formats.image.bmp;

import digigun.formats.FormatCodec;
import digigun.formats.FormatResult;
import digigun.formats.image.TextureData;
import haxe.io.Bytes;

/**
 * Convenience codec that combines `BmpReader` and `BmpWriter`.
 */
class BmpCodec implements FormatCodec<Bytes, TextureData, Bytes> {
  final reader:BmpReader;
  final writer:BmpWriter;

  /**
   * Creates a new BMP codec, optionally reusing reader/writer instances.
   */
  public function new(?reader:BmpReader, ?writer:BmpWriter) {
    this.reader = reader == null ? new BmpReader() : reader;
    this.writer = writer == null ? new BmpWriter() : writer;
  }

  /**
   * Parses BMP bytes into texture data.
   */
  public function read(input:Bytes):FormatResult<TextureData> {
    return reader.read(input);
  }

  /**
   * Serializes texture data into BMP bytes.
   */
  public function write(value:TextureData):FormatResult<Bytes> {
    return writer.write(value);
  }
}
