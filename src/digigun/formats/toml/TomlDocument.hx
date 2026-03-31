package digigun.formats.toml;

/**
 * Editable document model for the supported TOML subset.
 */
class TomlDocument {
  /** Properties declared before any named table. */
  public final globalProperties:Array<TomlProperty>;
  /** Named tables contained in the document. */
  public final tables:Array<TomlTable>;

  /**
   * Creates a new TOML document.
   */
  public function new(?globalProperties:Array<TomlProperty>, ?tables:Array<TomlTable>) {
    this.globalProperties = globalProperties == null ? [] : globalProperties.copy();
    this.tables = tables == null ? [] : tables.copy();
  }

  /**
   * Returns the first global property with the matching key, if present.
   */
  public function getGlobalProperty(key:String):Null<TomlProperty> {
    for (property in globalProperties) {
      if (property.key == key) {
        return property;
      }
    }

    return null;
  }

  /**
   * Returns whether a global property with the given key exists.
   */
  public function hasGlobalProperty(key:String):Bool {
    return getGlobalProperty(key) != null;
  }

  /**
   * Sets a global property value in place, creating the property when missing.
   */
  public function setGlobalProperty(key:String, value:TomlValue):TomlProperty {
    var existing = getGlobalProperty(key);
    if (existing != null) {
      existing.value = value;
      return existing;
    }

    var property = new TomlProperty(key, value);
    globalProperties.push(property);
    return property;
  }

  /**
   * Removes the first global property with the given key.
   */
  public function removeGlobalProperty(key:String):Bool {
    for (index in 0...globalProperties.length) {
      if (globalProperties[index].key == key) {
        globalProperties.splice(index, 1);
        return true;
      }
    }

    return false;
  }

  /**
   * Returns the first table with the matching name, if present.
   */
  public function getTable(name:String):Null<TomlTable> {
    for (table in tables) {
      if (table.name == name) {
        return table;
      }
    }

    return null;
  }

  /**
   * Returns whether a table with the given name exists.
   */
  public function hasTable(name:String):Bool {
    return getTable(name) != null;
  }

  /**
   * Returns an existing table or creates one in place when it does not exist.
   */
  public function getOrCreateTable(name:String):TomlTable {
    var existing = getTable(name);
    if (existing != null) {
      return existing;
    }

    var table = new TomlTable(name);
    tables.push(table);
    return table;
  }

  /**
   * Removes the first table with the given name.
   */
  public function removeTable(name:String):Bool {
    for (index in 0...tables.length) {
      if (tables[index].name == name) {
        tables.splice(index, 1);
        return true;
      }
    }

    return false;
  }

  /**
   * Returns a copy of the document with one more global property.
   */
  public function withGlobalProperty(key:String, value:TomlValue):TomlDocument {
    var nextGlobalProperties = globalProperties.copy();
    nextGlobalProperties.push(new TomlProperty(key, value));
    return new TomlDocument(nextGlobalProperties, tables);
  }

  /**
   * Returns a copy of the document with an additional table.
   */
  public function withTable(table:TomlTable):TomlDocument {
    var nextTables = tables.copy();
    nextTables.push(table);
    return new TomlDocument(globalProperties, nextTables);
  }
}
