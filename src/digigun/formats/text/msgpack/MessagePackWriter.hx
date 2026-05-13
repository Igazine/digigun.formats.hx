package digigun.formats.text.msgpack;

import digigun.formats.FormatError;
import digigun.formats.FormatErrorCode;
import digigun.formats.FormatResult;
import digigun.formats.FormatWriter;
import digigun.formats.text.msgpack.MessagePackValue.MessagePackValueData;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import haxe.io.FPHelper;

/**
 * Serializes a `MessagePackDocument` into deterministic MessagePack bytes.
 */
class MessagePackWriter implements FormatWriter<MessagePackDocument, Bytes> {
  /**
   * Creates a new MessagePack writer.
   */
  public function new() {}

  /**
   * Serializes the provided MessagePack document to bytes.
   */
  public function write(value:MessagePackDocument):FormatResult<Bytes> {
    var buffer = new BytesBuffer();
    var result = writeValue(buffer, value.root);
    return switch (result) {
      case Failure(errorValue):
        Failure(errorValue);
      case Success(_):
        Success(buffer.getBytes());
    };
  }

  function writeValue(buffer:BytesBuffer, value:MessagePackValue):FormatResult<Bool> {
    return switch (cast(value, MessagePackValueData)) {
      case VNull:
        buffer.addByte(0xc0);
        Success(true);
      case VBool(boolValue):
        buffer.addByte(boolValue ? 0xc3 : 0xc2);
        Success(true);
      case VInt(intValue):
        writeInt(buffer, intValue);
        Success(true);
      case VFloat(floatValue):
        writeFloat64(buffer, floatValue);
        Success(true);
      case VString(stringValue):
        writeString(buffer, stringValue);
      case VBytes(bytesValue):
        writeBytes(buffer, bytesValue);
      case VArray(arrayValue):
        writeArray(buffer, arrayValue);
      case VMap(mapValue):
        writeMap(buffer, mapValue);
    };
  }

  function writeInt(buffer:BytesBuffer, value:Int):Void {
    if (value >= 0 && value <= 0x7f) {
      buffer.addByte(value);
      return;
    }

    if (value >= -32 && value < 0) {
      buffer.addByte(value + 256);
      return;
    }

    if (value >= 0 && value <= 0xff) {
      buffer.addByte(0xcc);
      buffer.addByte(value);
      return;
    }

    if (value >= 0 && value <= 0xffff) {
      buffer.addByte(0xcd);
      writeUInt16(buffer, value);
      return;
    }

    if (value >= -0x80 && value < 0) {
      buffer.addByte(0xd0);
      buffer.addByte(value + 256);
      return;
    }

    if (value >= -0x8000 && value <= 0x7fff) {
      buffer.addByte(0xd1);
      writeUInt16(buffer, value & 0xffff);
      return;
    }

    if (value >= 0) {
      buffer.addByte(0xce);
      writeInt32(buffer, value);
      return;
    }

    buffer.addByte(0xd2);
    writeInt32(buffer, value);
  }

  function writeFloat64(buffer:BytesBuffer, value:Float):Void {
    buffer.addByte(0xcb);
    var bits = FPHelper.doubleToI64(value);
    writeInt32(buffer, bits.high);
    writeInt32(buffer, bits.low);
  }

  function writeString(buffer:BytesBuffer, value:String):FormatResult<Bool> {
    var bytes = Bytes.ofString(value);
    var length = bytes.length;

    if (length <= 31) {
      buffer.addByte(0xa0 | length);
    } else if (length <= 0xff) {
      buffer.addByte(0xd9);
      buffer.addByte(length);
    } else if (length <= 0xffff) {
      buffer.addByte(0xda);
      writeUInt16(buffer, length);
    } else {
      buffer.addByte(0xdb);
      writeInt32(buffer, length);
    }

    buffer.add(bytes);
    return Success(true);
  }

  function writeBytes(buffer:BytesBuffer, value:Bytes):FormatResult<Bool> {
    var length = value.length;
    if (length <= 0xff) {
      buffer.addByte(0xc4);
      buffer.addByte(length);
    } else if (length <= 0xffff) {
      buffer.addByte(0xc5);
      writeUInt16(buffer, length);
    } else {
      buffer.addByte(0xc6);
      writeInt32(buffer, length);
    }
    buffer.add(value);
    return Success(true);
  }

  function writeArray(buffer:BytesBuffer, value:MessagePackArray):FormatResult<Bool> {
    var length = value.items.length;
    if (length <= 15) {
      buffer.addByte(0x90 | length);
    } else if (length <= 0xffff) {
      buffer.addByte(0xdc);
      writeUInt16(buffer, length);
    } else {
      buffer.addByte(0xdd);
      writeInt32(buffer, length);
    }

    for (item in value.items) {
      switch (writeValue(buffer, item)) {
        case Failure(errorValue):
          return Failure(errorValue);
        case Success(_):
      }
    }

    return Success(true);
  }

  function writeMap(buffer:BytesBuffer, value:MessagePackMap):FormatResult<Bool> {
    var length = value.entries.length;
    if (length <= 15) {
      buffer.addByte(0x80 | length);
    } else if (length <= 0xffff) {
      buffer.addByte(0xde);
      writeUInt16(buffer, length);
    } else {
      buffer.addByte(0xdf);
      writeInt32(buffer, length);
    }

    for (entry in value.entries) {
      switch (writeValue(buffer, entry.key)) {
        case Failure(errorValue):
          return Failure(errorValue);
        case Success(_):
      }

      switch (writeValue(buffer, entry.value)) {
        case Failure(errorValue):
          return Failure(errorValue);
        case Success(_):
      }
    }

    return Success(true);
  }

  function writeUInt16(buffer:BytesBuffer, value:Int):Void {
    buffer.addByte((value >>> 8) & 0xff);
    buffer.addByte(value & 0xff);
  }

  function writeInt32(buffer:BytesBuffer, value:Int):Void {
    buffer.addByte((value >>> 24) & 0xff);
    buffer.addByte((value >>> 16) & 0xff);
    buffer.addByte((value >>> 8) & 0xff);
    buffer.addByte(value & 0xff);
  }
}
