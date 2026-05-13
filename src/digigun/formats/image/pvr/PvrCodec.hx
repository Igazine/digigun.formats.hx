package digigun.formats.image.pvr;

import digigun.formats.FormatCodec;
import digigun.formats.FormatResult;
import digigun.formats.image.TextureData;
import haxe.io.Bytes;

class PvrCodec implements FormatCodec<Bytes, TextureData, Bytes> {
  final reader:PvrReader;
  final writer:PvrWriter;

  public function new(?reader:PvrReader, ?writer:PvrWriter) {
    this.reader = reader == null ? new PvrReader() : reader;
    this.writer = writer == null ? new PvrWriter() : writer;
  }

  public function read(input:Bytes):FormatResult<TextureData> {
    return reader.read(input);
  }

  public function write(value:TextureData):FormatResult<Bytes> {
    return writer.write(value);
  }
}
