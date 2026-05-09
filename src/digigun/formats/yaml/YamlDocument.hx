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

  /**
   * Returns the first root property with the given key when the root is a mapping.
   */
  public inline function getProperty(key:String):Null<YamlProperty> {
    var objectValue = getRootObject();
    return objectValue == null ? null : objectValue.getProperty(key);
  }

  /**
   * Sets a root property, creating the root mapping when needed.
   */
  public inline function setProperty(key:String, value:YamlValue):YamlProperty {
    return getOrCreateRootObject().setProperty(key, value);
  }

  /**
   * Removes a root property when the root is a mapping.
   */
  public inline function removeProperty(key:String):Bool {
    var objectValue = getRootObject();
    return objectValue == null ? false : objectValue.removeProperty(key);
  }
}
