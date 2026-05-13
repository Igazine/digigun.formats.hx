package digigun.formats.text.yaml;

import digigun.formats.text.yaml.YamlValue.YamlValueData;

/**
 * Convenience helpers for explicit YAML value construction and extraction.
 */
class YamlValues {
  /** Wraps a string as a `YamlValue`. */
  public static function ofString(value:String):YamlValue {
    return value;
  }

  /** Wraps an integer as a `YamlValue`. */
  public static function ofInt(value:Int):YamlValue {
    return value;
  }

  /** Wraps a float as a `YamlValue`. */
  public static function ofFloat(value:Float):YamlValue {
    return value;
  }

  /** Wraps a boolean as a `YamlValue`. */
  public static function ofBool(value:Bool):YamlValue {
    return value;
  }

  /** Returns a YAML null value. */
  public static function nullValue():YamlValue {
    return cast YamlValueData.VNull;
  }

  /** Wraps a YAML object as a `YamlValue`. */
  public static function ofObject(value:YamlObject):YamlValue {
    return value;
  }

  /** Wraps a YAML array as a `YamlValue`. */
  public static function ofArray(value:YamlArray):YamlValue {
    return value;
  }
}
