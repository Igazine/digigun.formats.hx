package digigun.formats.yaml;

/**
 * Represents a mutable YAML mapping property.
 */
class YamlProperty {
  /** Property key. */
  public var key:String;
  /** Property value. */
  public var value:YamlValue;

  /**
   * Creates a new YAML property.
   */
  public function new(key:String, value:YamlValue) {
    this.key = key;
    this.value = value;
  }
}

