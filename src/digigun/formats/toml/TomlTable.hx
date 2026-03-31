package digigun.formats.toml;

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
  public function setProperty(key:String, value:TomlValue):TomlProperty {
    var existing = getProperty(key);
    if (existing != null) {
      existing.value = value;
      return existing;
    }

    var property = new TomlProperty(key, value);
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

  /**
   * Returns a copy of the table with an additional property appended.
   */
  public function withProperty(key:String, value:TomlValue):TomlTable {
    var nextProperties = properties.copy();
    nextProperties.push(new TomlProperty(key, value));
    return new TomlTable(name, nextProperties);
  }
}
