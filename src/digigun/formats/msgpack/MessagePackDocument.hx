package digigun.formats.msgpack;

/**
 * Editable document model for the supported MessagePack subset.
 */
class MessagePackDocument {
  /** Root MessagePack value. */
  public var root:MessagePackValue;

  /**
   * Creates a new MessagePack document.
   */
  public function new(?root:MessagePackValue) {
    this.root = root == null ? MessagePackValues.ofMap(new MessagePackMap()) : root;
  }

  /**
   * Replaces the root value.
   */
  public function setRoot(value:MessagePackValue):MessagePackValue {
    root = value;
    return root;
  }

  /**
   * Returns the root as a map when it is currently a map.
   */
  public inline function getRootMap():Null<MessagePackMap> {
    return root.asMap();
  }

  /**
   * Returns the root as an array when it is currently an array.
   */
  public inline function getRootArray():Null<MessagePackArray> {
    return root.asArray();
  }

  /**
   * Returns the root as a map, creating one when the root is not a map.
   */
  public function getOrCreateRootMap():MessagePackMap {
    var existing = root.asMap();
    if (existing != null) {
      return existing;
    }
    var created = new MessagePackMap();
    root = created;
    return created;
  }

  /**
   * Returns the root as an array, creating one when the root is not an array.
   */
  public function getOrCreateRootArray():MessagePackArray {
    var existing = root.asArray();
    if (existing != null) {
      return existing;
    }
    var created = new MessagePackArray();
    root = created;
    return created;
  }
}

