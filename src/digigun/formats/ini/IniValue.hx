package digigun.formats.ini;

/**
 * Internal tagged representation for INI scalar values.
 */
enum IniValueData {
  VString(value:String);
  VInt(value:Int);
  VFloat(value:Float);
  VBool(value:Bool);
}

/**
 * Strongly typed INI scalar value with implicit conversion from basic Haxe types.
 */
abstract IniValue(IniValueData) from IniValueData {
  /**
   * Wraps a low-level `IniValueData` value.
   */
  public inline function new(value:IniValueData) {
    this = value;
  }

  @:from public static inline function fromString(value:String):IniValue {
    return cast VString(value);
  }

  @:from public static inline function fromInt(value:Int):IniValue {
    return cast VInt(value);
  }

  @:from public static inline function fromFloat(value:Float):IniValue {
    return cast VFloat(value);
  }

  @:from public static inline function fromBool(value:Bool):IniValue {
    return cast VBool(value);
  }

  /**
   * Returns the value as a string, coercing scalar types as needed.
   */
  public inline function asString():String {
    return switch ((this : IniValueData)) {
      case VString(value):
        value;
      case VInt(value):
        Std.string(value);
      case VFloat(value):
        Std.string(value);
      case VBool(value):
        value ? "true" : "false";
    };
  }

  /**
   * Returns the value as an `Int` when it is backed by an integer.
   */
  public inline function asInt():Null<Int> {
    return switch ((this : IniValueData)) {
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
    return switch ((this : IniValueData)) {
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
    return switch ((this : IniValueData)) {
      case VBool(value):
        value;
      case _:
        null;
    };
  }
}
