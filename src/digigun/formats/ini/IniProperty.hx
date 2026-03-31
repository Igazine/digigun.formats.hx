package digigun.formats.ini;

/**
 * Represents a single INI key/value entry.
 */
class IniProperty {
  /** Property name. */
  public var key:String;
  /** Strongly typed property value. */
  public var value:IniValue;

  /**
   * Creates a new INI property.
   */
  public function new(key:String, value:IniValue) {
    this.key = key;
    this.value = value;
  }
}
