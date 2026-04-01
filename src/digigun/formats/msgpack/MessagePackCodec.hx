package digigun.formats.msgpack;

import digigun.formats.FormatCodec;
import digigun.formats.FormatResult;
import haxe.io.Bytes;

/**
 * Convenience codec that combines `MessagePackReader` and `MessagePackWriter`.
 */
class MessagePackCodec implements FormatCodec<Bytes, MessagePackDocument, Bytes> {
  final reader:MessagePackReader;
  final writer:MessagePackWriter;

  /**
   * Creates a new MessagePack codec, optionally reusing custom reader/writer instances.
   */
  public function new(?reader:MessagePackReader, ?writer:MessagePackWriter) {
    this.reader = reader == null ? new MessagePackReader() : reader;
    this.writer = writer == null ? new MessagePackWriter() : writer;
  }

  /**
   * Parses MessagePack bytes into a `MessagePackDocument`.
   */
  public function read(input:Bytes):FormatResult<MessagePackDocument> {
    return reader.read(input);
  }

  /**
   * Serializes a `MessagePackDocument` into MessagePack bytes.
   */
  public function write(value:MessagePackDocument):FormatResult<Bytes> {
    return writer.write(value);
  }
}
