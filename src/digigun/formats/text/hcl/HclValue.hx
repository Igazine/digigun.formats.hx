package digigun.formats.text.hcl;

/**
 * Internal tagged representation for HCL values in the supported subset.
 */
enum HclValueData {
  VString(value:String);
  VInt(value:Int);
  VFloat(value:Float);
  VBool(value:Bool);
  VNull;
  VArray(value:HclArray);
  VObject(value:HclObject);
}

/**
 * Strongly typed HCL value with implicit conversion from common Haxe types.
 */
abstract HclValue(HclValueData) from HclValueData {
  /**
   * Wraps a low-level `HclValueData` value.
   */
  public inline function new(value:HclValueData) {
    this = value;
  }

  @:from public static inline function fromString(value:String):HclValue {
    return cast VString(value);
  }

  @:from public static inline function fromInt(value:Int):HclValue {
    return cast VInt(value);
  }

  @:from public static inline function fromFloat(value:Float):HclValue {
    return cast VFloat(value);
  }

  @:from public static inline function fromBool(value:Bool):HclValue {
    return cast VBool(value);
  }

  @:from public static inline function fromArray(value:HclArray):HclValue {
    return cast VArray(value);
  }

  @:from public static inline function fromObject(value:HclObject):HclValue {
    return cast VObject(value);
  }

  @:from public static inline function fromIntArray(values:Array<Int>):HclValue {
    var output = new Array<HclValue>();
    for (value in values) {
      output.push(value);
    }
    return cast VArray(new HclArray(output));
  }

  @:from public static inline function fromStringArray(values:Array<String>):HclValue {
    var output = new Array<HclValue>();
    for (value in values) {
      output.push(value);
    }
    return cast VArray(new HclArray(output));
  }

  @:from public static inline function fromValueArray(values:Array<HclValue>):HclValue {
    return cast VArray(new HclArray(values));
  }

  /**
   * Returns the value as a string when possible.
   */
  public inline function asString():Null<String> {
    return switch ((this : HclValueData)) {
      case VString(value): value;
      case VInt(value): Std.string(value);
      case VFloat(value): Std.string(value);
      case VBool(value): value ? "true" : "false";
      case VNull: "null";
      case VArray(_) | VObject(_): null;
    };
  }

  /**
   * Returns the value as an integer when possible.
   */
  public inline function asInt():Null<Int> {
    return switch ((this : HclValueData)) {
      case VInt(value): value;
      case _ : null;
    };
  }

  /**
   * Returns the value as a float when possible.
   */
  public inline function asFloat():Null<Float> {
    return switch ((this : HclValueData)) {
      case VFloat(value): value;
      case VInt(value): value;
      case _ : null;
    };
  }

  /**
   * Returns the value as a boolean when possible.
   */
  public inline function asBool():Null<Bool> {
    return switch ((this : HclValueData)) {
      case VBool(value): value;
      case _ : null;
    };
  }

  /**
   * Returns whether the value is HCL null.
   */
  public inline function isNull():Bool {
    return switch ((this : HclValueData)) {
      case VNull: true;
      case _ : false;
    };
  }

  /**
   * Returns the value as an array when possible.
   */
  public inline function asArray():Null<HclArray> {
    return switch ((this : HclValueData)) {
      case VArray(value): value;
      case _ : null;
    };
  }

  /**
   * Returns the value as an object when possible.
   */
  public inline function asObject():Null<HclObject> {
    return switch ((this : HclValueData)) {
      case VObject(value): value;
      case _ : null;
    };
  }
}

