package digigun.formats.internal;

/**
 * Shared helpers for mutable structured data containers used by multiple formats.
 */
class StructuredDataTools {
  /**
   * Returns the item at the given index, if present.
   */
  public static function getAt<T>(items:Array<T>, index:Int):Null<T> {
    return index >= 0 && index < items.length ? items[index] : null;
  }

  /**
   * Returns whether an item exists at the given index.
   */
  public static function hasAt<T>(items:Array<T>, index:Int):Bool {
    return getAt(items, index) != null;
  }

  /**
   * Sets the item at the given index, expanding the array with generated values when needed.
   */
  public static function setAt<T>(items:Array<T>, index:Int, value:T, createMissing:()->T):T {
    while (items.length <= index) {
      items.push(createMissing());
    }
    items[index] = value;
    return value;
  }

  /**
   * Removes the item at the given index.
   */
  public static function removeAt<T>(items:Array<T>, index:Int):Bool {
    if (index < 0 || index >= items.length) {
      return false;
    }
    items.splice(index, 1);
    return true;
  }

  /**
   * Returns the first item whose selected key matches the requested string.
   */
  public static function findByStringKey<T>(items:Array<T>, key:String, getKey:T->Null<String>):Null<T> {
    for (item in items) {
      var candidate = getKey(item);
      if (candidate != null && candidate == key) {
        return item;
      }
    }
    return null;
  }

  /**
   * Returns whether an item exists for the requested string key.
   */
  public static function hasByStringKey<T>(items:Array<T>, key:String, getKey:T->Null<String>):Bool {
    return findByStringKey(items, key, getKey) != null;
  }

  /**
   * Sets an item selected by string key, creating it when missing.
   */
  public static function setByStringKey<T, TValue>(
    items:Array<T>,
    key:String,
    value:TValue,
    getKey:T->Null<String>,
    setValue:(T, TValue)->Void,
    create:(String, TValue)->T
  ):T {
    var existing = findByStringKey(items, key, getKey);
    if (existing != null) {
      setValue(existing, value);
      return existing;
    }

    var created = create(key, value);
    items.push(created);
    return created;
  }

  /**
   * Removes the first item whose selected key matches the requested string.
   */
  public static function removeByStringKey<T>(items:Array<T>, key:String, getKey:T->Null<String>):Bool {
    for (index in 0...items.length) {
      var candidate = getKey(items[index]);
      if (candidate != null && candidate == key) {
        items.splice(index, 1);
        return true;
      }
    }
    return false;
  }

  /**
   * Returns the first item that matches the provided predicate.
   */
  public static function findByMatch<T>(items:Array<T>, matches:T->Bool):Null<T> {
    for (item in items) {
      if (matches(item)) {
        return item;
      }
    }
    return null;
  }

  /**
   * Returns an existing matching item or creates a new one.
   */
  public static function getOrCreateByMatch<T>(items:Array<T>, matches:T->Bool, create:()->T):T {
    var existing = findByMatch(items, matches);
    if (existing != null) {
      return existing;
    }

    var created = create();
    items.push(created);
    return created;
  }

  /**
   * Removes the first item that matches the provided predicate.
   */
  public static function removeByMatch<T>(items:Array<T>, matches:T->Bool):Bool {
    for (index in 0...items.length) {
      if (matches(items[index])) {
        items.splice(index, 1);
        return true;
      }
    }
    return false;
  }
}
