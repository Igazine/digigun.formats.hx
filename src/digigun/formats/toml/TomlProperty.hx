package digigun.formats.toml;

/**
 * Represents a single TOML key/value entry.
 */
class TomlProperty {
  /** Property name. */
  public var key:String;
  /** Strongly typed property value. */
  public var value:TomlValue;

  /**
   * Creates a new TOML property.
   */
  public function new(key:String, value:TomlValue) {
    this.key = key;
    this.value = value;
  }
}
