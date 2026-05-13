package digigun.formats.text.msgpack;

import haxe.io.Bytes;

/**
 * Internal tagged representation for MessagePack values in the supported subset.
 */
enum MessagePackValueData {
  VNull;
  VBool(value:Bool);
  VInt(value:Int);
  VFloat(value:Float);
  VString(value:String);
  VBytes(value:Bytes);
  VArray(value:MessagePackArray);
  VMap(value:MessagePackMap);
}

/**
 * Strongly typed MessagePack value with implicit conversion from common Haxe types.
 */
abstract MessagePackValue(MessagePackValueData) from MessagePackValueData {
  /**
   * Wraps a low-level `MessagePackValueData` value.
   */
  public inline function new(value:MessagePackValueData) {
    this = value;
  }

  @:from public static inline function fromBool(value:Bool):MessagePackValue {
    return cast VBool(value);
  }

  @:from public static inline function fromInt(value:Int):MessagePackValue {
    return cast VInt(value);
  }

  @:from public static inline function fromFloat(value:Float):MessagePackValue {
    return cast VFloat(value);
  }

  @:from public static inline function fromString(value:String):MessagePackValue {
    return cast VString(value);
  }

  @:from public static inline function fromBytes(value:Bytes):MessagePackValue {
    return cast VBytes(value);
  }

  @:from public static inline function fromArray(value:MessagePackArray):MessagePackValue {
    return cast VArray(value);
  }

  @:from public static inline function fromMap(value:MessagePackMap):MessagePackValue {
    return cast VMap(value);
  }

  @:from public static inline function fromValueArray(values:Array<MessagePackValue>):MessagePackValue {
    return cast VArray(new MessagePackArray(values));
  }

  @:from public static inline function fromIntArray(values:Array<Int>):MessagePackValue {
    var output = new Array<MessagePackValue>();
    for (value in values) {
      output.push(value);
    }
    return cast VArray(new MessagePackArray(output));
  }

  @:from public static inline function fromStringArray(values:Array<String>):MessagePackValue {
    var output = new Array<MessagePackValue>();
    for (value in values) {
      output.push(value);
    }
    return cast VArray(new MessagePackArray(output));
  }

  /**
   * Returns whether the value is MessagePack nil.
   */
  public inline function isNull():Bool {
    return switch ((this : MessagePackValueData)) {
      case VNull:
        true;
      case _:
        false;
    };
  }

  /**
   * Returns the value as a boolean when possible.
   */
  public inline function asBool():Null<Bool> {
    return switch ((this : MessagePackValueData)) {
      case VBool(value):
        value;
      case _:
        null;
    };
  }

  /**
   * Returns the value as an integer when possible.
   */
  public inline function asInt():Null<Int> {
    return switch ((this : MessagePackValueData)) {
      case VInt(value):
        value;
      case _:
        null;
    };
  }

  /**
   * Returns the value as a float when possible.
   */
  public inline function asFloat():Null<Float> {
    return switch ((this : MessagePackValueData)) {
      case VFloat(value):
        value;
      case VInt(value):
        value;
      case _:
        null;
    };
  }

  /**
   * Returns the value as a string when possible.
   */
  public inline function asString():Null<String> {
    return switch ((this : MessagePackValueData)) {
      case VString(value):
        value;
      case _:
        null;
    };
  }

  /**
   * Returns the value as raw bytes when possible.
   */
  public inline function asBytes():Null<Bytes> {
    return switch ((this : MessagePackValueData)) {
      case VBytes(value):
        value;
      case _:
        null;
    };
  }

  /**
   * Returns the value as an array when possible.
   */
  public inline function asArray():Null<MessagePackArray> {
    return switch ((this : MessagePackValueData)) {
      case VArray(value):
        value;
      case _:
        null;
    };
  }

  /**
   * Returns the value as a map when possible.
   */
  public inline function asMap():Null<MessagePackMap> {
    return switch ((this : MessagePackValueData)) {
      case VMap(value):
        value;
      case _:
        null;
    };
  }
}

