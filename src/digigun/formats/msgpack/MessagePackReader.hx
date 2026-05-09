package digigun.formats.msgpack;

import digigun.formats.FormatError;
import digigun.formats.FormatErrorCode;
import digigun.formats.FormatReader;
import digigun.formats.FormatResult;
import digigun.formats.msgpack.MessagePackValue.MessagePackValueData;
import haxe.io.Bytes;
import haxe.io.FPHelper;

/**
 * Parses MessagePack bytes into a `MessagePackDocument`.
 */
class MessagePackReader implements FormatReader<Bytes, MessagePackDocument> {
  var bytes:Bytes;
  var position:Int;

  /**
   * Creates a new MessagePack reader.
   */
  public function new() {}

  /**
   * Parses MessagePack bytes into a mutable document model.
   */
  public function read(input:Bytes):FormatResult<MessagePackDocument> {
    bytes = input;
    position = 0;

    var parsed = readValue();
    return switch (parsed) {
      case Failure(error):
        Failure(error);
      case Success(value):
        if (position != bytes.length) {
          Failure(error(FormatErrorCode.InvalidStructure, "Trailing data after MessagePack root value."));
        } else {
          Success(new MessagePackDocument(value));
        }
    };
  }

  function readValue():FormatResult<MessagePackValue> {
    if (!hasRemaining(1)) {
      return Failure(error(FormatErrorCode.InvalidStructure, "Unexpected end of MessagePack input."));
    }

    var code = readByte();

    if (code <= 0x7f) {
      return Success(code);
    }

    if (code >= 0xe0) {
      return Success(code - 256);
    }

    if (code >= 0xa0 && code <= 0xbf) {
      return readString(code & 0x1f);
    }

    if (code >= 0x90 && code <= 0x9f) {
      return readArray(code & 0x0f);
    }

    if (code >= 0x80 && code <= 0x8f) {
      return readMap(code & 0x0f);
    }

    return switch (code) {
      case 0xc0:
        Success(MessagePackValues.nullValue());
      case 0xc2:
        Success(false);
      case 0xc3:
        Success(true);
      case 0xc4:
        readBytes(readUInt8());
      case 0xc5:
        readBytes(readUInt16());
      case 0xc6:
        readBytes(readLength32());
      case 0xca:
        readFloat32();
      case 0xcb:
        readFloat64();
      case 0xcc:
        Success(readUInt8());
      case 0xcd:
        Success(readUInt16());
      case 0xce:
        readUInt32AsInt();
      case 0xcf:
        Failure(error(FormatErrorCode.UnsupportedFeature, "64-bit unsigned integers are not supported."));
      case 0xd0:
        Success(readInt8());
      case 0xd1:
        Success(readInt16());
      case 0xd2:
        Success(readInt32());
      case 0xd3:
        Failure(error(FormatErrorCode.UnsupportedFeature, "64-bit signed integers are not supported."));
      case 0xd9:
        readString(readUInt8());
      case 0xda:
        readString(readUInt16());
      case 0xdb:
        readString(readLength32());
      case 0xdc:
        readArray(readUInt16());
      case 0xdd:
        readArray(readLength32());
      case 0xde:
        readMap(readUInt16());
      case 0xdf:
        readMap(readLength32());
      default:
        Failure(error(FormatErrorCode.UnsupportedFeature, 'Unsupported MessagePack type byte 0x${StringTools.hex(code, 2).toLowerCase()}.'));
    };
  }

  function readBytes(length:Int):FormatResult<MessagePackValue> {
    if (!hasRemaining(length)) {
      return Failure(error(FormatErrorCode.InvalidStructure, "Unexpected end of MessagePack bytes payload."));
    }

    var value = bytes.sub(position, length);
    position += length;
    return Success(value);
  }

  function readString(length:Int):FormatResult<MessagePackValue> {
    if (!hasRemaining(length)) {
      return Failure(error(FormatErrorCode.InvalidStructure, "Unexpected end of MessagePack string payload."));
    }

    var value = bytes.sub(position, length).toString();
    position += length;
    return Success(value);
  }

  function readArray(length:Int):FormatResult<MessagePackValue> {
    var items = new Array<MessagePackValue>();
    for (index in 0...length) {
      switch (readValue()) {
        case Failure(errorValue):
          return Failure(errorValue);
        case Success(value):
          items.push(value);
      }
    }
    return Success(new MessagePackArray(items));
  }

  function readMap(length:Int):FormatResult<MessagePackValue> {
    var map = new MessagePackMap();
    for (index in 0...length) {
      var key = readValue();
      switch (key) {
        case Failure(errorValue):
          return Failure(errorValue);
        case Success(parsedKey):
          switch (readValue()) {
            case Failure(errorValue):
              return Failure(errorValue);
            case Success(parsedValue):
              map.addEntry(parsedKey, parsedValue);
          }
      }
    }
    return Success(map);
  }

  function readFloat32():FormatResult<MessagePackValue> {
    if (!hasRemaining(4)) {
      return Failure(error(FormatErrorCode.InvalidStructure, "Unexpected end of MessagePack float32 payload."));
    }
    var bits = readRawInt32();
    return Success(FPHelper.i32ToFloat(bits));
  }

  function readFloat64():FormatResult<MessagePackValue> {
    if (!hasRemaining(8)) {
      return Failure(error(FormatErrorCode.InvalidStructure, "Unexpected end of MessagePack float64 payload."));
    }
    var high = readRawInt32();
    var low = readRawInt32();
    return Success(FPHelper.i64ToDouble(low, high));
  }

  function readUInt32AsInt():FormatResult<MessagePackValue> {
    var value = readRawInt32();
    if (value < 0) {
      return Failure(error(FormatErrorCode.UnsupportedFeature, "32-bit unsigned integers above Int range are not supported."));
    }
    return Success(value);
  }

  inline function readUInt8():Int {
    return readByte();
  }

  function readUInt16():Int {
    var a = readByte();
    var b = readByte();
    return (a << 8) | b;
  }

  function readInt8():Int {
    var value = readByte();
    return value >= 0x80 ? value - 0x100 : value;
  }

  function readInt16():Int {
    var value = readUInt16();
    return value >= 0x8000 ? value - 0x10000 : value;
  }

  function readInt32():Int {
    return readRawInt32();
  }

  function readLength32():Int {
    var value = readRawInt32();
    if (value < 0) {
      return -1;
    }
    return value;
  }

  function readRawInt32():Int {
    var a = readByte();
    var b = readByte();
    var c = readByte();
    var d = readByte();
    return (a << 24) | (b << 16) | (c << 8) | d;
  }

  inline function readByte():Int {
    var value = bytes.get(position);
    position++;
    return value;
  }

  inline function hasRemaining(length:Int):Bool {
    return position + length <= bytes.length;
  }

  inline function error(code:FormatErrorCode, message:String):FormatError {
    return new FormatError(code, message, null, MessagePackFormat.id);
  }
}
