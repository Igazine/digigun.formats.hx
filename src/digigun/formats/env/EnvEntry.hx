package digigun.formats.env;

/**
 * Represents a mutable `.env` entry.
 */
class EnvEntry {
  /** Variable name. */
  public var key:String;
  /** Variable value. */
  public var value:String;
  /** Whether the entry should be written with the `export` prefix. */
  public var exported:Bool;

  /**
   * Creates a new env entry.
   */
  public function new(key:String, value:String, ?exported:Bool) {
    this.key = key;
    this.value = value;
    this.exported = exported == null ? false : exported;
  }
}

