package digigun.formats.image.internal;

import haxe.io.Bytes;

/**
 * Shared binary helpers for image container formats.
 */
class BinaryTools {
  public static function readUInt16LE(bytes:Bytes, offset:Int):Int {
    return bytes.get(offset) | (bytes.get(offset + 1) << 8);
  }

  public static function readUInt32LE(bytes:Bytes, offset:Int):Int {
    return bytes.get(offset)
      | (bytes.get(offset + 1) << 8)
      | (bytes.get(offset + 2) << 16)
      | (bytes.get(offset + 3) << 24);
  }

  public static function readUInt16BE(bytes:Bytes, offset:Int):Int {
    return (bytes.get(offset) << 8) | bytes.get(offset + 1);
  }

  public static function readUInt32BE(bytes:Bytes, offset:Int):Int {
    return (bytes.get(offset) << 24)
      | (bytes.get(offset + 1) << 16)
      | (bytes.get(offset + 2) << 8)
      | bytes.get(offset + 3);
  }

  public static function writeUInt16LE(bytes:Bytes, offset:Int, value:Int):Void {
    bytes.set(offset, value & 0xff);
    bytes.set(offset + 1, (value >> 8) & 0xff);
  }

  public static function writeUInt32LE(bytes:Bytes, offset:Int, value:Int):Void {
    bytes.set(offset, value & 0xff);
    bytes.set(offset + 1, (value >> 8) & 0xff);
    bytes.set(offset + 2, (value >> 16) & 0xff);
    bytes.set(offset + 3, (value >> 24) & 0xff);
  }

  public static function align4(value:Int):Int {
    return (value + 3) & ~3;
  }

  public static function fourCC(value:String):Int {
    return value.charCodeAt(0)
      | (value.charCodeAt(1) << 8)
      | (value.charCodeAt(2) << 16)
      | (value.charCodeAt(3) << 24);
  }
}
