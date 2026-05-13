package digigun.formats.text.yaml;

/**
 * Internal tagged representation for YAML values in the supported subset.
 */
enum YamlValueData {
  VString(value:String);
  VInt(value:Int);
  VFloat(value:Float);
  VBool(value:Bool);
  VNull;
  VArray(value:YamlArray);
  VObject(value:YamlObject);
}

/**
 * Strongly typed YAML value with implicit conversion from common Haxe types.
 */
abstract YamlValue(YamlValueData) from YamlValueData {
  /**
   * Wraps a low-level `YamlValueData` value.
   */
  public inline function new(value:YamlValueData) {
    this = value;
  }

  @:from public static inline function fromString(value:String):YamlValue {
    return cast VString(value);
  }

  @:from public static inline function fromInt(value:Int):YamlValue {
    return cast VInt(value);
  }

  @:from public static inline function fromFloat(value:Float):YamlValue {
    return cast VFloat(value);
  }

  @:from public static inline function fromBool(value:Bool):YamlValue {
    return cast VBool(value);
  }

  @:from public static inline function fromObject(value:YamlObject):YamlValue {
    return cast VObject(value);
  }

  @:from public static inline function fromArray(value:YamlArray):YamlValue {
    return cast VArray(value);
  }

  @:from public static inline function fromValueArray(values:Array<YamlValue>):YamlValue {
    return cast VArray(new YamlArray(values));
  }

  @:from public static inline function fromIntArray(values:Array<Int>):YamlValue {
    var output = new Array<YamlValue>();
    for (value in values) {
      output.push(value);
    }
    return cast VArray(new YamlArray(output));
  }

  @:from public static inline function fromFloatArray(values:Array<Float>):YamlValue {
    var output = new Array<YamlValue>();
    for (value in values) {
      output.push(value);
    }
    return cast VArray(new YamlArray(output));
  }

  @:from public static inline function fromBoolArray(values:Array<Bool>):YamlValue {
    var output = new Array<YamlValue>();
    for (value in values) {
      output.push(value);
    }
    return cast VArray(new YamlArray(output));
  }

  @:from public static inline function fromStringArray(values:Array<String>):YamlValue {
    var output = new Array<YamlValue>();
    for (value in values) {
      output.push(value);
    }
    return cast VArray(new YamlArray(output));
  }

  /**
   * Returns the value as a string when possible.
   */
  public inline function asString():Null<String> {
    return switch ((this : YamlValueData)) {
      case VString(value):
        value;
      case VInt(value):
        Std.string(value);
      case VFloat(value):
        Std.string(value);
      case VBool(value):
        value ? "true" : "false";
      case VNull:
        "null";
      case VArray(_) | VObject(_):
        null;
    };
  }

  /**
   * Returns the value as an integer when it is backed by an integer.
   */
  public inline function asInt():Null<Int> {
    return switch ((this : YamlValueData)) {
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
    return switch ((this : YamlValueData)) {
      case VFloat(value):
        value;
      case VInt(value):
        value;
      case _:
        null;
    };
  }

  /**
   * Returns the value as a boolean when possible.
   */
  public inline function asBool():Null<Bool> {
    return switch ((this : YamlValueData)) {
      case VBool(value):
        value;
      case _:
        null;
    };
  }

  /**
   * Returns whether the value is YAML null.
   */
  public inline function isNull():Bool {
    return switch ((this : YamlValueData)) {
      case VNull:
        true;
      case _:
        false;
    };
  }

  /**
   * Returns the value as a YAML array when possible.
   */
  public inline function asArray():Null<YamlArray> {
    return switch ((this : YamlValueData)) {
      case VArray(value):
        value;
      case _:
        null;
    };
  }

  /**
   * Returns the value as a YAML object when possible.
   */
  public inline function asObject():Null<YamlObject> {
    return switch ((this : YamlValueData)) {
      case VObject(value):
        value;
      case _:
        null;
    };
  }
}

