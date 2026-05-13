package digigun.formats.text.hcl;

/**
 * Editable document model for the supported HCL2 subset.
 */
class HclDocument {
  /** Root body. */
  public final body:HclBody;

  /**
   * Creates a new HCL document.
   */
  public function new(?body:HclBody) {
    this.body = body == null ? new HclBody() : body;
  }

  /**
   * Returns the first root attribute with the given name, if present.
   */
  public inline function getAttribute(name:String):Null<HclAttribute> {
    return body.getAttribute(name);
  }

  /**
   * Sets a root attribute in place.
   */
  public inline function setAttribute(name:String, value:HclValue):HclAttribute {
    return body.setAttribute(name, value);
  }

  /**
   * Adds a root block.
   */
  public inline function addBlock(type:String, ?labels:Array<String>, ?blockBody:HclBody):HclBlock {
    return body.addBlock(type, labels, blockBody);
  }

  /**
   * Returns an existing root block or creates one when missing.
   */
  public inline function getOrCreateBlock(type:String, ?labels:Array<String>):HclBlock {
    return body.getOrCreateBlock(type, labels);
  }
}
