package digigun.formats.msgpack;

import digigun.formats.internal.StructuredDataTools;

/**
 * Represents a mutable MessagePack array.
 */
class MessagePackArray {
  /** Sequence items in order. */
  public final items:Array<MessagePackValue>;

  /**
   * Creates a new MessagePack array.
   */
  public function new(?items:Array<MessagePackValue>) {
    this.items = items == null ? [] : items.copy();
  }

  /**
   * Returns the item at the given index, if present.
   */
  public function get(index:Int):Null<MessagePackValue> {
    return StructuredDataTools.getAt(items, index);
  }

  /**
   * Returns whether an item exists at the given index.
   */
  public function has(index:Int):Bool {
    return StructuredDataTools.hasAt(items, index);
  }

  /**
   * Appends a new value to the array.
   */
  public function add(value:MessagePackValue):MessagePackValue {
    items.push(value);
    return value;
  }

  /**
   * Sets a value at the given index, expanding with null values when needed.
   */
  public function set(index:Int, value:MessagePackValue):MessagePackValue {
    return StructuredDataTools.setAt(items, index, value, MessagePackValues.nullValue);
  }

  /**
   * Removes the item at the given index.
   */
  public function remove(index:Int):Bool {
    return StructuredDataTools.removeAt(items, index);
  }
}
