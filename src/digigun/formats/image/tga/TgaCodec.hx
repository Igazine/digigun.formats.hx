package digigun.formats.image.tga;

import digigun.formats.FormatCodec;
import digigun.formats.FormatResult;
import digigun.formats.image.TextureData;
import haxe.io.Bytes;

class TgaCodec implements FormatCodec<Bytes, TextureData, Bytes> {
  final reader:TgaReader;
  final writer:TgaWriter;

  public function new(?reader:TgaReader, ?writer:TgaWriter) {
    this.reader = reader == null ? new TgaReader() : reader;
    this.writer = writer == null ? new TgaWriter() : writer;
  }

  public function read(input:Bytes):FormatResult<TextureData> {
    return reader.read(input);
  }

  public function write(value:TextureData):FormatResult<Bytes> {
    return writer.write(value);
  }
}
