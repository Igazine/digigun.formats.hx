package digigun.formats.text.msgpack;

/**
 * Represents a mutable MessagePack map entry.
 */
class MessagePackEntry {
  /** Entry key. */
  public var key:MessagePackValue;
  /** Entry value. */
  public var value:MessagePackValue;

  /**
   * Creates a new MessagePack entry.
   */
  public function new(key:MessagePackValue, value:MessagePackValue) {
    this.key = key;
    this.value = value;
  }
}

