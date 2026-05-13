package digigun.formats.image.dds;

import digigun.formats.FormatCodec;
import digigun.formats.FormatResult;
import digigun.formats.image.TextureData;
import haxe.io.Bytes;

class DdsCodec implements FormatCodec<Bytes, TextureData, Bytes> {
  final reader:DdsReader;
  final writer:DdsWriter;

  public function new(?reader:DdsReader, ?writer:DdsWriter) {
    this.reader = reader == null ? new DdsReader() : reader;
    this.writer = writer == null ? new DdsWriter() : writer;
  }

  public function read(input:Bytes):FormatResult<TextureData> {
    return reader.read(input);
  }

  public function write(value:TextureData):FormatResult<Bytes> {
    return writer.write(value);
  }
}
