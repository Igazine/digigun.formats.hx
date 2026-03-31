package digigun.formats.yaml;

/**
 * Represents a mutable YAML mapping.
 */
class YamlObject {
  /** Properties in insertion order. */
  public final properties:Array<YamlProperty>;

  /**
   * Creates a new YAML object.
   */
  public function new(?properties:Array<YamlProperty>) {
    this.properties = properties == null ? [] : properties.copy();
  }

  /**
   * Returns the first property with the matching key, if present.
   */
  public function getProperty(key:String):Null<YamlProperty> {
    for (property in properties) {
      if (property.key == key) {
        return property;
      }
    }
    return null;
  }

  /**
   * Returns whether a property with the given key exists.
   */
  public function hasProperty(key:String):Bool {
    return getProperty(key) != null;
  }

  /**
   * Sets a property value in place, creating the property when missing.
   */
  public function setProperty(key:String, value:YamlValue):YamlProperty {
    var existing = getProperty(key);
    if (existing != null) {
      existing.value = value;
      return existing;
    }

    var property = new YamlProperty(key, value);
    properties.push(property);
    return property;
  }

  /**
   * Removes the first property with the given key.
   */
  public function removeProperty(key:String):Bool {
    for (index in 0...properties.length) {
      if (properties[index].key == key) {
        properties.splice(index, 1);
        return true;
      }
    }
    return false;
  }
}

