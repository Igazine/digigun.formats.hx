package digigun.formats.hcl;

/**
 * Represents a mutable object field in an HCL expression.
 */
class HclObjectField {
  /** Field key. */
  public var key:String;
  /** Field value. */
  public var value:HclValue;

  /**
   * Creates a new object field.
   */
  public function new(key:String, value:HclValue) {
    this.key = key;
    this.value = value;
  }
}

