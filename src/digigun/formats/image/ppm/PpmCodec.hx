package digigun.formats.image.ppm;

import digigun.formats.FormatCodec;
import digigun.formats.FormatResult;
import digigun.formats.image.TextureData;
import haxe.io.Bytes;

class PpmCodec implements FormatCodec<Bytes, TextureData, Bytes> {
  final reader:PpmReader;
  final writer:PpmWriter;

  public function new(?reader:PpmReader, ?writer:PpmWriter) {
    this.reader = reader == null ? new PpmReader() : reader;
    this.writer = writer == null ? new PpmWriter() : writer;
  }

  public function read(input:Bytes):FormatResult<TextureData> {
    return reader.read(input);
  }

  public function write(value:TextureData):FormatResult<Bytes> {
    return writer.write(value);
  }
}
