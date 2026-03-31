package digigun.formats.csv;

/**
 * Editable document model for CSV data.
 */
class CsvDocument {
  /** Rows contained in the document. */
  public final rows:Array<CsvRow>;

  /**
   * Creates a new CSV document.
   */
  public function new(?rows:Array<CsvRow>) {
    this.rows = rows == null ? [] : rows.copy();
  }

  /**
   * Returns the row at the given index, if present.
   */
  public function getRow(index:Int):Null<CsvRow> {
    return index >= 0 && index < rows.length ? rows[index] : null;
  }

  /**
   * Returns whether a row exists at the given index.
   */
  public inline function hasRow(index:Int):Bool {
    return getRow(index) != null;
  }

  /**
   * Appends an empty row.
   */
  public function addRow(?values:Array<String>):CsvRow {
    var row = new CsvRow();
    if (values != null) {
      for (value in values) {
        row.addCell(value);
      }
    }
    rows.push(row);
    return row;
  }

  /**
   * Returns an existing row or creates rows up to the requested index.
   */
  public function getOrCreateRow(index:Int):CsvRow {
    while (rows.length <= index) {
      rows.push(new CsvRow());
    }
    return rows[index];
  }

  /**
   * Removes the row at the given index.
   */
  public function removeRow(index:Int):Bool {
    if (index < 0 || index >= rows.length) {
      return false;
    }

    rows.splice(index, 1);
    return true;
  }
}
