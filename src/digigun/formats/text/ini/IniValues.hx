package digigun.formats.text.ini;

/**
 * Convenience helpers for explicit INI value construction and extraction.
 *
 * These helpers are optional because `IniValue` also supports implicit
 * conversion from Haxe literals.
 */
class IniValues {
  /** Wraps a string as an `IniValue`. */
  public static function ofString(value:String):IniValue {
    return value;
  }

  /** Wraps an integer as an `IniValue`. */
  public static function ofInt(value:Int):IniValue {
    return value;
  }

  /** Wraps a float as an `IniValue`. */
  public static function ofFloat(value:Float):IniValue {
    return value;
  }

  /** Wraps a boolean as an `IniValue`. */
  public static function ofBool(value:Bool):IniValue {
    return value;
  }

  /** Returns the value as a string, coercing scalars as needed. */
  public static function asString(value:IniValue):Null<String> {
    return value.asString();
  }

  /** Returns the value as an integer when possible. */
  public static function asInt(value:IniValue):Null<Int> {
    return value.asInt();
  }

  /** Returns the value as a float when possible. */
  public static function asFloat(value:IniValue):Null<Float> {
    return value.asFloat();
  }

  /** Returns the value as a boolean when possible. */
  public static function asBool(value:IniValue):Null<Bool> {
    return value.asBool();
  }
}
