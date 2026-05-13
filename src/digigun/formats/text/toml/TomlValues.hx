package digigun.formats.text.toml;

/**
 * Convenience helpers for explicit TOML value construction and extraction.
 *
 * These helpers are optional because `TomlValue` also supports implicit
 * conversion from Haxe literals and literal arrays.
 */
class TomlValues {
  /** Wraps a string as a `TomlValue`. */
  public static function ofString(value:String):TomlValue {
    return value;
  }

  /** Wraps an integer as a `TomlValue`. */
  public static function ofInt(value:Int):TomlValue {
    return value;
  }

  /** Wraps a float as a `TomlValue`. */
  public static function ofFloat(value:Float):TomlValue {
    return value;
  }

  /** Wraps a boolean as a `TomlValue`. */
  public static function ofBool(value:Bool):TomlValue {
    return value;
  }

  /** Wraps an array of TOML values as a `TomlValue`. */
  public static function ofArray(values:Array<TomlValue>):TomlValue {
    return values;
  }

  /** Wraps a TOML object as a `TomlValue`. */
  public static function ofObject(value:TomlObject):TomlValue {
    return value;
  }

  /** Returns the value as a string when possible. */
  public static function asString(value:TomlValue):Null<String> {
    return value.asString();
  }

  /** Returns the value as an integer when possible. */
  public static function asInt(value:TomlValue):Null<Int> {
    return value.asInt();
  }

  /** Returns the value as a float when possible. */
  public static function asFloat(value:TomlValue):Null<Float> {
    return value.asFloat();
  }

  /** Returns the value as a boolean when possible. */
  public static function asBool(value:TomlValue):Null<Bool> {
    return value.asBool();
  }

  /** Returns the value as an array when possible. */
  public static function asArray(value:TomlValue):Null<Array<TomlValue>> {
    return value.asArray();
  }

  /** Returns the value as an object when possible. */
  public static function asObject(value:TomlValue):Null<TomlObject> {
    return value.asObject();
  }
}
