package digigun.formats.yaml;

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
    return index >= 0 && index < items.length ? items[index] : null;
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
    while (items.length <= index) {
      items.push(YamlValues.nullValue());
    }
    items[index] = value;
    return value;
  }

  /**
   * Removes the item at the given index.
   */
  public function remove(index:Int):Bool {
    if (index < 0 || index >= items.length) {
      return false;
    }
    items.splice(index, 1);
    return true;
  }
}

