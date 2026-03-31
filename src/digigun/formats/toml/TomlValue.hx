package digigun.formats.toml;

/**
 * Internal tagged representation for TOML values in the supported subset.
 */
enum TomlValueData {
  VString(value:String);
  VInt(value:Int);
  VFloat(value:Float);
  VBool(value:Bool);
  VArray(values:Array<TomlValue>);
}

/**
 * Strongly typed TOML value with implicit conversion from common Haxe types.
 */
abstract TomlValue(TomlValueData) from TomlValueData {
  /**
   * Wraps a low-level `TomlValueData` value.
   */
  public inline function new(value:TomlValueData) {
    this = value;
  }

  @:from public static inline function fromString(value:String):TomlValue {
    return cast VString(value);
  }

  @:from public static inline function fromInt(value:Int):TomlValue {
    return cast VInt(value);
  }

  @:from public static inline function fromFloat(value:Float):TomlValue {
    return cast VFloat(value);
  }

  @:from public static inline function fromBool(value:Bool):TomlValue {
    return cast VBool(value);
  }

  @:from public static inline function fromValueArray(values:Array<TomlValue>):TomlValue {
    return cast VArray(values.copy());
  }

  @:from public static inline function fromIntArray(values:Array<Int>):TomlValue {
    var output = new Array<TomlValue>();
    for (value in values) {
      output.push(value);
    }
    return cast VArray(output);
  }

  @:from public static inline function fromFloatArray(values:Array<Float>):TomlValue {
    var output = new Array<TomlValue>();
    for (value in values) {
      output.push(value);
    }
    return cast VArray(output);
  }

  @:from public static inline function fromBoolArray(values:Array<Bool>):TomlValue {
    var output = new Array<TomlValue>();
    for (value in values) {
      output.push(value);
    }
    return cast VArray(output);
  }

  @:from public static inline function fromStringArray(values:Array<String>):TomlValue {
    var output = new Array<TomlValue>();
    for (value in values) {
      output.push(value);
    }
    return cast VArray(output);
  }

  /**
   * Returns the value as a string when possible.
   */
  public inline function asString():Null<String> {
    return switch ((this : TomlValueData)) {
      case VString(value):
        value;
      case VInt(value):
        Std.string(value);
      case VFloat(value):
        Std.string(value);
      case VBool(value):
        value ? "true" : "false";
      case VArray(_):
        null;
    };
  }

  /**
   * Returns the value as an `Int` when it is backed by an integer.
   */
  public inline function asInt():Null<Int> {
    return switch ((this : TomlValueData)) {
      case VInt(value):
        value;
      case _:
        null;
    };
  }

  /**
   * Returns the value as a `Float` when possible.
   */
  public inline function asFloat():Null<Float> {
    return switch ((this : TomlValueData)) {
      case VFloat(value):
        value;
      case VInt(value):
        value;
      case _:
        null;
    };
  }

  /**
   * Returns the value as a `Bool` when it is backed by a boolean.
   */
  public inline function asBool():Null<Bool> {
    return switch ((this : TomlValueData)) {
      case VBool(value):
        value;
      case _:
        null;
    };
  }

  /**
   * Returns the value as an array when it is backed by a TOML array.
   */
  public inline function asArray():Null<Array<TomlValue>> {
    return switch ((this : TomlValueData)) {
      case VArray(values):
        values.copy();
      case _:
        null;
    };
  }
}
