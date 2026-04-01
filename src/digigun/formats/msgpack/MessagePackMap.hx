package digigun.formats.msgpack;

import digigun.formats.internal.StructuredDataTools;
import digigun.formats.msgpack.MessagePackValue.MessagePackValueData;

/**
 * Represents a mutable MessagePack map.
 */
class MessagePackMap {
  /** Entries in insertion order. */
  public final entries:Array<MessagePackEntry>;

  /**
   * Creates a new MessagePack map.
   */
  public function new(?entries:Array<MessagePackEntry>) {
    this.entries = entries == null ? [] : entries.copy();
  }

  /**
   * Appends a generic entry to the map.
   */
  public function addEntry(key:MessagePackValue, value:MessagePackValue):MessagePackEntry {
    var entry = new MessagePackEntry(key, value);
    entries.push(entry);
    return entry;
  }

  /**
   * Returns the first entry whose key is the matching string.
   */
  public function getProperty(key:String):Null<MessagePackEntry> {
    return StructuredDataTools.findByStringKey(entries, key, entryKey);
  }

  /**
   * Returns whether a string-keyed property exists.
   */
  public function hasProperty(key:String):Bool {
    return StructuredDataTools.hasByStringKey(entries, key, entryKey);
  }

  /**
   * Sets a string-keyed property in place, creating it when missing.
   */
  public function setProperty(key:String, value:MessagePackValue):MessagePackEntry {
    return StructuredDataTools.setByStringKey(
      entries,
      key,
      value,
      entryKey,
      function(entry, nextValue) entry.value = nextValue,
      function(name, nextValue) return new MessagePackEntry(name, nextValue)
    );
  }

  /**
   * Removes the first string-keyed property with the given key.
   */
  public function removeProperty(key:String):Bool {
    return StructuredDataTools.removeByStringKey(entries, key, entryKey);
  }

  function entryKey(entry:MessagePackEntry):Null<String> {
    return switch (cast(entry.key, MessagePackValueData)) {
      case VString(value):
        value;
      case _:
        null;
    };
  }
}
