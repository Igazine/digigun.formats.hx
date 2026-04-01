package digigun.formats.hcl;

/**
 * Represents a mutable HCL attribute.
 */
class HclAttribute {
  /** Attribute name. */
  public var name:String;
  /** Attribute value. */
  public var value:HclValue;

  /**
   * Creates a new HCL attribute.
   */
  public function new(name:String, value:HclValue) {
    this.name = name;
    this.value = value;
  }
}

