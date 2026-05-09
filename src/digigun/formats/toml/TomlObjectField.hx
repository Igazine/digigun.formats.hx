package digigun.formats.toml;

/**
 * Represents a mutable field in a TOML inline table.
 */
class TomlObjectField {
  /** Field key. */
  public var key:String;
  /** Field value. */
  public var value:TomlValue;

  /**
   * Creates a new TOML object field.
   */
  public function new(key:String, value:TomlValue) {
    this.key = key;
    this.value = value;
  }
}
