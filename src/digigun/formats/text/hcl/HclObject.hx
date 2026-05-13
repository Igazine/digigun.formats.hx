package digigun.formats.text.hcl;

import digigun.formats.internal.StructuredDataTools;

/**
 * Represents a mutable HCL object constructor value.
 */
class HclObject {
  /** Fields in insertion order. */
  public final fields:Array<HclObjectField>;

  /**
   * Creates a new HCL object.
   */
  public function new(?fields:Array<HclObjectField>) {
    this.fields = fields == null ? [] : fields.copy();
  }

  /**
   * Returns the first field with the given key, if present.
   */
  public function getField(key:String):Null<HclObjectField> {
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
  public function setField(key:String, value:HclValue):HclObjectField {
    return StructuredDataTools.setByStringKey(
      fields,
      key,
      value,
      function(field) return field.key,
      function(field, nextValue) field.value = nextValue,
      function(name, nextValue) return new HclObjectField(name, nextValue)
    );
  }

  /**
   * Removes the first field with the given key.
   */
  public function removeField(key:String):Bool {
    return StructuredDataTools.removeByStringKey(fields, key, function(field) return field.key);
  }
}
