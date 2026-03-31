package digigun.formats.properties;

/**
 * Editable document model for `.properties` files.
 */
class PropertiesDocument {
  /** Entries in insertion order. */
  public final entries:Array<PropertiesEntry>;

  /**
   * Creates a new properties document.
   */
  public function new(?entries:Array<PropertiesEntry>) {
    this.entries = entries == null ? [] : entries.copy();
  }

  /**
   * Returns the first entry with the given key, if present.
   */
  public function getEntry(key:String):Null<PropertiesEntry> {
    for (entry in entries) {
      if (entry.key == key) {
        return entry;
      }
    }
    return null;
  }

  /**
   * Alias for `getEntry` for consistency with property-oriented formats.
   */
  public inline function getProperty(key:String):Null<PropertiesEntry> {
    return getEntry(key);
  }

  /**
   * Returns whether the given key exists.
   */
  public function hasEntry(key:String):Bool {
    return getEntry(key) != null;
  }

  /**
   * Alias for `hasEntry` for consistency with property-oriented formats.
   */
  public inline function hasProperty(key:String):Bool {
    return hasEntry(key);
  }

  /**
   * Sets an entry in place, creating it when missing.
   */
  public function setEntry(key:String, value:String):PropertiesEntry {
    var existing = getEntry(key);
    if (existing != null) {
      existing.value = value;
      return existing;
    }

    var entry = new PropertiesEntry(key, value);
    entries.push(entry);
    return entry;
  }

  /**
   * Alias for `setEntry` for consistency with property-oriented formats.
   */
  public inline function setProperty(key:String, value:String):PropertiesEntry {
    return setEntry(key, value);
  }

  /**
   * Removes the first entry with the given key.
   */
  public function removeEntry(key:String):Bool {
    for (index in 0...entries.length) {
      if (entries[index].key == key) {
        entries.splice(index, 1);
        return true;
      }
    }
    return false;
  }

  /**
   * Alias for `removeEntry` for consistency with property-oriented formats.
   */
  public inline function removeProperty(key:String):Bool {
    return removeEntry(key);
  }
}
