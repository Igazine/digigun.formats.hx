package digigun.formats.text.msgpack;

import digigun.formats.text.msgpack.MessagePackValue.MessagePackValueData;
import haxe.io.Bytes;

/**
 * Convenience helpers for explicit MessagePack value construction and extraction.
 */
class MessagePackValues {
  /** Returns a MessagePack nil value. */
  public static function nullValue():MessagePackValue {
    return cast MessagePackValueData.VNull;
  }

  /** Wraps a boolean as a `MessagePackValue`. */
  public static function ofBool(value:Bool):MessagePackValue {
    return value;
  }

  /** Wraps an integer as a `MessagePackValue`. */
  public static function ofInt(value:Int):MessagePackValue {
    return value;
  }

  /** Wraps a float as a `MessagePackValue`. */
  public static function ofFloat(value:Float):MessagePackValue {
    return value;
  }

  /** Wraps a string as a `MessagePackValue`. */
  public static function ofString(value:String):MessagePackValue {
    return value;
  }

  /** Wraps bytes as a `MessagePackValue`. */
  public static function ofBytes(value:Bytes):MessagePackValue {
    return value;
  }

  /** Wraps an array as a `MessagePackValue`. */
  public static function ofArray(value:MessagePackArray):MessagePackValue {
    return value;
  }

  /** Wraps a map as a `MessagePackValue`. */
  public static function ofMap(value:MessagePackMap):MessagePackValue {
    return value;
  }
}

