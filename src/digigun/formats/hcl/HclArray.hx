package digigun.formats.hcl;

import digigun.formats.internal.StructuredDataTools;

/**
 * Represents a mutable HCL array constructor value.
 */
class HclArray {
  /** Items in order. */
  public final items:Array<HclValue>;

  /**
   * Creates a new HCL array.
   */
  public function new(?items:Array<HclValue>) {
    this.items = items == null ? [] : items.copy();
  }

  /**
   * Returns the item at the given index, if present.
   */
  public function get(index:Int):Null<HclValue> {
    return StructuredDataTools.getAt(items, index);
  }

  /**
   * Returns whether an item exists at the given index.
   */
  public function has(index:Int):Bool {
    return StructuredDataTools.hasAt(items, index);
  }

  /**
   * Appends a new item.
   */
  public function add(value:HclValue):HclValue {
    items.push(value);
    return value;
  }

  /**
   * Sets an item at the given index, expanding with `null` values when needed.
   */
  public function set(index:Int, value:HclValue):HclValue {
    return StructuredDataTools.setAt(items, index, value, HclValues.nullValue);
  }

  /**
   * Removes the item at the given index.
   */
  public function remove(index:Int):Bool {
    return StructuredDataTools.removeAt(items, index);
  }
}
