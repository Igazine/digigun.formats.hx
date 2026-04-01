package digigun.formats.toml;

import digigun.formats.internal.StructuredDataTools;

/**
 * Represents a named TOML table and its editable properties.
 */
class TomlTable {
  /** Table name. */
  public var name:String;
  /** Properties contained in this table. */
  public final properties:Array<TomlProperty>;

  /**
   * Creates a new TOML table.
   */
  public function new(name:String, ?properties:Array<TomlProperty>) {
    this.name = name;
    this.properties = properties == null ? [] : properties.copy();
  }

  /**
   * Returns the first property with the matching key, if present.
   */
  public function getProperty(key:String):Null<TomlProperty> {
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
  public function setProperty(key:String, value:TomlValue):TomlProperty {
    return StructuredDataTools.setByStringKey(
      properties,
      key,
      value,
      function(property) return property.key,
      function(property, nextValue) property.value = nextValue,
      function(name, nextValue) return new TomlProperty(name, nextValue)
    );
  }

  /**
   * Removes the first property with the given key.
   */
  public function removeProperty(key:String):Bool {
    return StructuredDataTools.removeByStringKey(properties, key, function(property) return property.key);
  }

  /**
   * Returns a copy of the table with an additional property appended.
   */
  public function withProperty(key:String, value:TomlValue):TomlTable {
    var nextProperties = properties.copy();
    nextProperties.push(new TomlProperty(key, value));
    return new TomlTable(name, nextProperties);
  }
}
