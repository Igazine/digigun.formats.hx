package digigun.formats.toml;

import digigun.formats.internal.StructuredDataTools;

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
    return StructuredDataTools.findByStringKey(globalProperties, key, function(property) return property.key);
  }

  /**
   * Returns whether a global property with the given key exists.
   */
  public function hasGlobalProperty(key:String):Bool {
    return StructuredDataTools.hasByStringKey(globalProperties, key, function(property) return property.key);
  }

  /**
   * Sets a global property value in place, creating the property when missing.
   */
  public function setGlobalProperty(key:String, value:TomlValue):TomlProperty {
    return StructuredDataTools.setByStringKey(
      globalProperties,
      key,
      value,
      function(property) return property.key,
      function(property, nextValue) property.value = nextValue,
      function(name, nextValue) return new TomlProperty(name, nextValue)
    );
  }

  /**
   * Removes the first global property with the given key.
   */
  public function removeGlobalProperty(key:String):Bool {
    return StructuredDataTools.removeByStringKey(globalProperties, key, function(property) return property.key);
  }

  /**
   * Returns the first table with the matching name, if present.
   */
  public function getTable(name:String):Null<TomlTable> {
    return StructuredDataTools.findByStringKey(tables, name, function(table) return table.name);
  }

  /**
   * Returns whether a table with the given name exists.
   */
  public function hasTable(name:String):Bool {
    return StructuredDataTools.hasByStringKey(tables, name, function(table) return table.name);
  }

  /**
   * Returns an existing table or creates one in place when it does not exist.
   */
  public function getOrCreateTable(name:String):TomlTable {
    return StructuredDataTools.getOrCreateByMatch(
      tables,
      function(table) return table.name == name,
      function() return new TomlTable(name)
    );
  }

  /**
   * Removes the first table with the given name.
   */
  public function removeTable(name:String):Bool {
    return StructuredDataTools.removeByStringKey(tables, name, function(table) return table.name);
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
