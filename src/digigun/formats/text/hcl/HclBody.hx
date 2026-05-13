package digigun.formats.text.hcl;

import digigun.formats.internal.StructuredDataTools;

/**
 * Represents a mutable HCL body containing attributes and nested blocks.
 */
class HclBody {
  /** Attributes in insertion order. */
  public final attributes:Array<HclAttribute>;
  /** Blocks in insertion order. */
  public final blocks:Array<HclBlock>;

  /**
   * Creates a new HCL body.
   */
  public function new(?attributes:Array<HclAttribute>, ?blocks:Array<HclBlock>) {
    this.attributes = attributes == null ? [] : attributes.copy();
    this.blocks = blocks == null ? [] : blocks.copy();
  }

  /**
   * Returns the first attribute with the given name, if present.
   */
  public function getAttribute(name:String):Null<HclAttribute> {
    return StructuredDataTools.findByStringKey(attributes, name, function(attribute) return attribute.name);
  }

  /**
   * Returns whether the given attribute exists.
   */
  public function hasAttribute(name:String):Bool {
    return StructuredDataTools.hasByStringKey(attributes, name, function(attribute) return attribute.name);
  }

  /**
   * Sets an attribute in place, creating it when missing.
   */
  public function setAttribute(name:String, value:HclValue):HclAttribute {
    return StructuredDataTools.setByStringKey(
      attributes,
      name,
      value,
      function(attribute) return attribute.name,
      function(attribute, nextValue) attribute.value = nextValue,
      function(nextName, nextValue) return new HclAttribute(nextName, nextValue)
    );
  }

  /**
   * Removes the first attribute with the given name.
   */
  public function removeAttribute(name:String):Bool {
    return StructuredDataTools.removeByStringKey(attributes, name, function(attribute) return attribute.name);
  }

  /**
   * Adds a new block to the body.
   */
  public function addBlock(type:String, ?labels:Array<String>, ?body:HclBody):HclBlock {
    var block = new HclBlock(type, labels, body);
    blocks.push(block);
    return block;
  }

  /**
   * Returns the first block matching type and labels.
   */
  public function getBlock(type:String, ?labels:Array<String>):Null<HclBlock> {
    return StructuredDataTools.findByMatch(blocks, function(block) return block.type == type && labelsMatch(block.labels, labels));
  }

  /**
   * Returns an existing block or creates one when missing.
   */
  public function getOrCreateBlock(type:String, ?labels:Array<String>):HclBlock {
    return StructuredDataTools.getOrCreateByMatch(
      blocks,
      function(block) return block.type == type && labelsMatch(block.labels, labels),
      function() return new HclBlock(type, labels)
    );
  }

  /**
   * Removes the first block matching type and labels.
   */
  public function removeBlock(type:String, ?labels:Array<String>):Bool {
    return StructuredDataTools.removeByMatch(blocks, function(block) return block.type == type && labelsMatch(block.labels, labels));
  }

  function labelsMatch(actual:Array<String>, expected:Null<Array<String>>):Bool {
    if (expected == null) {
      return true;
    }
    if (actual.length != expected.length) {
      return false;
    }
    for (index in 0...actual.length) {
      if (actual[index] != expected[index]) {
        return false;
      }
    }
    return true;
  }
}
