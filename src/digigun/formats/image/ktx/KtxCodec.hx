package digigun.formats.image.ktx;

import digigun.formats.FormatCodec;
import digigun.formats.FormatResult;
import digigun.formats.image.TextureData;
import haxe.io.Bytes;

class KtxCodec implements FormatCodec<Bytes, TextureData, Bytes> {
  final reader:KtxReader;
  final writer:KtxWriter;

  public function new(?reader:KtxReader, ?writer:KtxWriter) {
    this.reader = reader == null ? new KtxReader() : reader;
    this.writer = writer == null ? new KtxWriter() : writer;
  }

  public function read(input:Bytes):FormatResult<TextureData> {
    return reader.read(input);
  }

  public function write(value:TextureData):FormatResult<Bytes> {
    return writer.write(value);
  }
}
