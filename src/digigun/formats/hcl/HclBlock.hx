package digigun.formats.hcl;

/**
 * Represents a mutable HCL block with optional labels.
 */
class HclBlock {
  /** Block type name. */
  public var type:String;
  /** Block labels in order. */
  public final labels:Array<String>;
  /** Block body. */
  public final body:HclBody;

  /**
   * Creates a new HCL block.
   */
  public function new(type:String, ?labels:Array<String>, ?body:HclBody) {
    this.type = type;
    this.labels = labels == null ? [] : labels.copy();
    this.body = body == null ? new HclBody() : body;
  }
}

