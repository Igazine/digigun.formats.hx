package digigun.formats.text.ini;

/**
 * Represents a named INI section and its editable properties.
 */
class IniSection {
  /** Section name. */
  public var name:String;
  /** Properties contained in this section. */
  public final properties:Array<IniProperty>;

  /**
   * Creates a new INI section.
   */
  public function new(name:String, ?properties:Array<IniProperty>) {
    this.name = name;
    this.properties = properties == null ? [] : properties.copy();
  }

  /**
   * Returns the first property with the matching key, if present.
   */
  public function getProperty(key:String):Null<IniProperty> {
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
  public function setProperty(key:String, value:IniValue):IniProperty {
    var existing = getProperty(key);
    if (existing != null) {
      existing.value = value;
      return existing;
    }

    var property = new IniProperty(key, value);
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
   * Returns a copy of the section with an additional property appended.
   */
  public function withProperty(key:String, value:IniValue):IniSection {
    var nextProperties = properties.copy();
    nextProperties.push(new IniProperty(key, value));
    return new IniSection(name, nextProperties);
  }
}
