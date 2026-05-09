package digigun.formats.toml;

import digigun.formats.internal.StructuredDataTools;

/**
 * Represents a mutable TOML inline table value.
 */
class TomlObject {
  /** Fields in insertion order. */
  public final fields:Array<TomlObjectField>;

  /**
   * Creates a new TOML object.
   */
  public function new(?fields:Array<TomlObjectField>) {
    this.fields = fields == null ? [] : fields.copy();
  }

  /**
   * Returns the first field with the given key, if present.
   */
  public function getField(key:String):Null<TomlObjectField> {
    return StructuredDataTools.findByStringKey(fields, key, function(field) return field.key);
  }

  /**
   * Returns whether the given key exists.
   */
  public function hasField(key:String):Bool {
    return StructuredDataTools.hasByStringKey(fields, key, function(field) return field.key);
  }

  /**
   * Sets a field in place, creating it when missing.
   */
  public function setField(key:String, value:TomlValue):TomlObjectField {
    return StructuredDataTools.setByStringKey(
      fields,
      key,
      value,
      function(field) return field.key,
      function(field, nextValue) field.value = nextValue,
      function(name, nextValue) return new TomlObjectField(name, nextValue)
    );
  }

  /**
   * Removes the first field with the given key.
   */
  public function removeField(key:String):Bool {
    return StructuredDataTools.removeByStringKey(fields, key, function(field) return field.key);
  }
}
