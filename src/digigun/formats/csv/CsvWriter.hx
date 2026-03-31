package digigun.formats.csv;

import StringTools;
import digigun.formats.FormatResult;
import digigun.formats.FormatWriter;

/**
 * Serializes a `CsvDocument` into deterministic CSV text.
 */
class CsvWriter implements FormatWriter<CsvDocument, String> {
  /** Delimiter used between cells. */
  public final delimiter:String;

  /**
   * Creates a new CSV writer.
   */
  public function new(?delimiter:String) {
    this.delimiter = delimiter == null ? "," : delimiter;
  }

  /**
   * Serializes the provided CSV document to text.
   */
  public function write(value:CsvDocument):FormatResult<String> {
    var lines = new Array<String>();
    for (row in value.rows) {
      var renderedCells = new Array<String>();
      for (cell in row.cells) {
        renderedCells.push(renderCell(cell.value));
      }
      lines.push(renderedCells.join(delimiter));
    }
    return Success(lines.join("\n"));
  }

  function renderCell(value:String):String {
    var needsQuotes = value.indexOf(delimiter) >= 0 || value.indexOf("\"") >= 0 || value.indexOf("\n") >= 0 || value.indexOf("\r") >= 0;
    if (!needsQuotes) {
      return value;
    }

    return '"' + StringTools.replace(value, "\"", "\"\"") + '"';
  }
}

