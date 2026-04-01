package digigun.formats.yaml;

import digigun.formats.internal.StructuredDataTools;

/**
 * Represents a mutable YAML sequence.
 */
class YamlArray {
  /** Sequence items in order. */
  public final items:Array<YamlValue>;

  /**
   * Creates a new YAML array.
   */
  public function new(?items:Array<YamlValue>) {
    this.items = items == null ? [] : items.copy();
  }

  /**
   * Returns the item at the given index, if present.
   */
  public function get(index:Int):Null<YamlValue> {
    return StructuredDataTools.getAt(items, index);
  }

  /**
   * Returns whether an item exists at the given index.
   */
  public function has(index:Int):Bool {
    return StructuredDataTools.hasAt(items, index);
  }

  /**
   * Appends a new item to the sequence.
   */
  public function add(value:YamlValue):YamlValue {
    items.push(value);
    return value;
  }

  /**
   * Sets an item at the given index, expanding with null values when needed.
   */
  public function set(index:Int, value:YamlValue):YamlValue {
    return StructuredDataTools.setAt(items, index, value, YamlValues.nullValue);
  }

  /**
   * Removes the item at the given index.
   */
  public function remove(index:Int):Bool {
    return StructuredDataTools.removeAt(items, index);
  }
}
