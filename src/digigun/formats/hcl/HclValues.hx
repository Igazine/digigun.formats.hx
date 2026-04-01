package digigun.formats.hcl;

import digigun.formats.hcl.HclValue.HclValueData;

/**
 * Convenience helpers for explicit HCL value construction and extraction.
 */
class HclValues {
  /** Returns an HCL null value. */
  public static function nullValue():HclValue {
    return cast HclValueData.VNull;
  }

  /** Wraps a string as an `HclValue`. */
  public static function ofString(value:String):HclValue {
    return value;
  }

  /** Wraps an integer as an `HclValue`. */
  public static function ofInt(value:Int):HclValue {
    return value;
  }

  /** Wraps a float as an `HclValue`. */
  public static function ofFloat(value:Float):HclValue {
    return value;
  }

  /** Wraps a boolean as an `HclValue`. */
  public static function ofBool(value:Bool):HclValue {
    return value;
  }

  /** Wraps an array as an `HclValue`. */
  public static function ofArray(value:HclArray):HclValue {
    return value;
  }

  /** Wraps an object as an `HclValue`. */
  public static function ofObject(value:HclObject):HclValue {
    return value;
  }
}

