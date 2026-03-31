package digigun.formats.csv;

/**
 * Represents a mutable CSV row.
 */
class CsvRow {
  /** Cells in the row. */
  public final cells:Array<CsvCell>;

  /**
   * Creates a new CSV row.
   */
  public function new(?cells:Array<CsvCell>) {
    this.cells = cells == null ? [] : cells.copy();
  }

  /**
   * Returns the cell at the given index, if present.
   */
  public function getCell(index:Int):Null<CsvCell> {
    return index >= 0 && index < cells.length ? cells[index] : null;
  }

  /**
   * Returns whether a cell exists at the given index.
   */
  public inline function hasCell(index:Int):Bool {
    return getCell(index) != null;
  }

  /**
   * Appends a new cell to the row.
   */
  public function addCell(value:String):CsvCell {
    var cell = new CsvCell(value);
    cells.push(cell);
    return cell;
  }

  /**
   * Sets a cell at the given index, expanding the row with empty cells when needed.
   */
  public function setCell(index:Int, value:String):CsvCell {
    while (cells.length <= index) {
      cells.push(new CsvCell(""));
    }

    cells[index].value = value;
    return cells[index];
  }

  /**
   * Removes the cell at the given index.
   */
  public function removeCell(index:Int):Bool {
    if (index < 0 || index >= cells.length) {
      return false;
    }

    cells.splice(index, 1);
    return true;
  }
}
