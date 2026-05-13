package digigun.formats.text.properties;

/**
 * Represents a mutable `.properties` entry.
 */
class PropertiesEntry {
  /** Entry key. */
  public var key:String;
  /** Entry value. */
  public var value:String;

  /**
   * Creates a new properties entry.
   */
  public function new(key:String, value:String) {
    this.key = key;
    this.value = value;
  }
}

