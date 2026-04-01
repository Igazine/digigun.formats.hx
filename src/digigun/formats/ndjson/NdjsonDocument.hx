package digigun.formats.ndjson;

/**
 * Editable document model for newline-delimited JSON.
 *
 * Record values are delegated to `haxe.Json`, so they are stored as parsed
 * JSON values rather than a custom JSON tree type in this library.
 */
class NdjsonDocument {
  /** JSON values in document order, one record per line. */
  public final records:Array<Dynamic>;

  /**
   * Creates a new NDJSON document.
   */
  public function new(?records:Array<Dynamic>) {
    this.records = records == null ? [] : records.copy();
  }

  /**
   * Returns the record at the given index, if present.
   */
  public function getRecord(index:Int):Dynamic {
    return index >= 0 && index < records.length ? records[index] : null;
  }

  /**
   * Returns whether a record exists at the given index.
   */
  public inline function hasRecord(index:Int):Bool {
    return index >= 0 && index < records.length;
  }

  /**
   * Appends a new record to the document.
   */
  public function addRecord(value:Dynamic):Dynamic {
    records.push(value);
    return value;
  }

  /**
   * Sets the record at the given index, expanding with `null` records when needed.
   */
  public function setRecord(index:Int, value:Dynamic):Dynamic {
    while (records.length <= index) {
      records.push(null);
    }
    records[index] = value;
    return value;
  }

  /**
   * Removes the record at the given index.
   */
  public function removeRecord(index:Int):Bool {
    if (index < 0 || index >= records.length) {
      return false;
    }
    records.splice(index, 1);
    return true;
  }
}

