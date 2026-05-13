package digigun.formats.image.raw;

import digigun.formats.FormatCodec;
import digigun.formats.FormatResult;
import digigun.formats.image.TextureData;
import haxe.io.Bytes;

/**
 * Convenience codec that combines `RawReader` and `RawWriter`.
 */
class RawCodec implements FormatCodec<Bytes, TextureData, Bytes> {
  final reader:RawReader;
  final writer:RawWriter;

  /**
   * Creates a new RAW codec from one shared image specification.
   */
  public function new(spec:RawImageSpec, ?reader:RawReader, ?writer:RawWriter) {
    this.reader = reader == null ? new RawReader(spec) : reader;
    this.writer = writer == null ? new RawWriter(spec) : writer;
  }

  /**
   * Parses RAW bytes into texture data.
   */
  public function read(input:Bytes):FormatResult<TextureData> {
    return reader.read(input);
  }

  /**
   * Serializes texture data into RAW bytes.
   */
  public function write(value:TextureData):FormatResult<Bytes> {
    return writer.write(value);
  }
}
