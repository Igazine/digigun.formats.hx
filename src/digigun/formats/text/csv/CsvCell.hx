package digigun.formats.text.csv;

/**
 * Represents a mutable CSV cell.
 */
class CsvCell {
  /** Cell text value. */
  public var value:String;

  /**
   * Creates a new CSV cell.
   */
  public function new(value:String) {
    this.value = value;
  }
}

