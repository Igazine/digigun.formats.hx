package digigun.formats.yaml;

/**
 * Editable document model for the supported YAML subset.
 */
class YamlDocument {
  /** Root YAML value. */
  public var root:YamlValue;

  /**
   * Creates a new YAML document.
   */
  public function new(?root:YamlValue) {
    this.root = root == null ? YamlValues.ofObject(new YamlObject()) : root;
  }

  /**
   * Replaces the root value.
   */
  public function setRoot(value:YamlValue):YamlValue {
    root = value;
    return root;
  }

  /**
   * Returns the root as an object when it is currently a mapping.
   */
  public inline function getRootObject():Null<YamlObject> {
    return root.asObject();
  }

  /**
   * Returns the root as an array when it is currently a sequence.
   */
  public inline function getRootArray():Null<YamlArray> {
    return root.asArray();
  }

  /**
   * Returns the root as an object, creating one when the root is not an object.
   */
  public function getOrCreateRootObject():YamlObject {
    var existing = root.asObject();
    if (existing != null) {
      return existing;
    }

    var created = new YamlObject();
    root = created;
    return created;
  }

  /**
   * Returns the root as an array, creating one when the root is not an array.
   */
  public function getOrCreateRootArray():YamlArray {
    var existing = root.asArray();
    if (existing != null) {
      return existing;
    }

    var created = new YamlArray();
    root = created;
    return created;
  }
}
