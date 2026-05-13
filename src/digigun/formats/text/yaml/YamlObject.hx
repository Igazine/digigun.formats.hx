package digigun.formats.text.yaml;

import digigun.formats.internal.StructuredDataTools;

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
    return StructuredDataTools.findByStringKey(properties, key, function(property) return property.key);
  }

  /**
   * Returns whether a property with the given key exists.
   */
  public function hasProperty(key:String):Bool {
    return StructuredDataTools.hasByStringKey(properties, key, function(property) return property.key);
  }

  /**
   * Sets a property value in place, creating the property when missing.
   */
  public function setProperty(key:String, value:YamlValue):YamlProperty {
    return StructuredDataTools.setByStringKey(
      properties,
      key,
      value,
      function(property) return property.key,
      function(property, nextValue) property.value = nextValue,
      function(name, nextValue) return new YamlProperty(name, nextValue)
    );
  }

  /**
   * Removes the first property with the given key.
   */
  public function removeProperty(key:String):Bool {
    return StructuredDataTools.removeByStringKey(properties, key, function(property) return property.key);
  }
}
