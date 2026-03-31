package digigun.formats;

/**
 * Describes a line and column location within a textual format source.
 */
class FormatLocation {
  /** 1-based line number. */
  public final line:Int;
  /** 1-based column number. */
  public final column:Int;

  /**
   * Creates a new source location.
   */
  public function new(line:Int, column:Int) {
    this.line = line;
    this.column = column;
  }

  /**
   * Returns a human-readable description of the location.
   */
  public function toString():String {
    return 'line ${line}, column ${column}';
  }
}
