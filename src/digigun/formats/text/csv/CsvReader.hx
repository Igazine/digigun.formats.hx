package digigun.formats.text.csv;

import digigun.formats.FormatError;
import digigun.formats.FormatErrorCode;
import digigun.formats.FormatLocation;
import digigun.formats.FormatReader;
import digigun.formats.FormatResult;
import digigun.formats.internal.TextFormatTools;

/**
 * Parses CSV text into a `CsvDocument`.
 */
class CsvReader implements FormatReader<String, CsvDocument> {
  /** Delimiter used between cells. */
  public final delimiter:String;

  /**
   * Creates a new CSV reader.
   */
  public function new(?delimiter:String) {
    this.delimiter = delimiter == null ? "," : delimiter;
  }

  /**
   * Parses CSV text into a mutable document model.
   */
  public function read(input:String):FormatResult<CsvDocument> {
    var normalized = TextFormatTools.normalizeNewlines(input);
    var rows = new Array<CsvRow>();
    var currentRow = new Array<CsvCell>();
    var currentCell = new StringBuf();
    var inQuotes = false;
    var justClosedQuotedCell = false;
    var line = 1;
    var column = 1;
    var index = 0;

    while (index < normalized.length) {
      var char = normalized.charAt(index);

      if (inQuotes) {
        if (char == "\"") {
          var nextIndex = index + 1;
          if (nextIndex < normalized.length && normalized.charAt(nextIndex) == "\"") {
            currentCell.add("\"");
            index += 2;
            column += 2;
            continue;
          }

          inQuotes = false;
          justClosedQuotedCell = true;
          index++;
          column++;
          continue;
        }

        currentCell.add(char);
        if (char == "\n") {
          line++;
          column = 1;
        } else {
          column++;
        }
        index++;
        continue;
      }

      if (justClosedQuotedCell) {
        if (char == delimiter) {
          currentRow.push(new CsvCell(currentCell.toString()));
          currentCell = new StringBuf();
          justClosedQuotedCell = false;
          index++;
          column++;
          continue;
        }

        if (char == "\n") {
          currentRow.push(new CsvCell(currentCell.toString()));
          rows.push(new CsvRow(currentRow));
          currentRow = [];
          currentCell = new StringBuf();
          justClosedQuotedCell = false;
          index++;
          line++;
          column = 1;
          continue;
        }

        return Failure(error("Unexpected characters after closing quoted CSV cell.", line, column));
      }

      if (char == "\"") {
        if (currentCell.toString() != "") {
          return Failure(error("Unexpected quote inside unquoted CSV cell.", line, column));
        }
        inQuotes = true;
        index++;
        column++;
        continue;
      }

      if (char == delimiter) {
        currentRow.push(new CsvCell(currentCell.toString()));
        currentCell = new StringBuf();
        index++;
        column++;
        continue;
      }

      if (char == "\n") {
        currentRow.push(new CsvCell(currentCell.toString()));
        rows.push(new CsvRow(currentRow));
        currentRow = [];
        currentCell = new StringBuf();
        index++;
        line++;
        column = 1;
        continue;
      }

      currentCell.add(char);
      index++;
      column++;
    }

    if (inQuotes) {
      return Failure(error("Unterminated quoted CSV cell.", line, column));
    }

    if (justClosedQuotedCell) {
      currentRow.push(new CsvCell(currentCell.toString()));
      currentCell = new StringBuf();
    }

    if (currentCell.toString() != "" || currentRow.length > 0 || normalized == "") {
      currentRow.push(new CsvCell(currentCell.toString()));
      rows.push(new CsvRow(currentRow));
    }

    if (rows.length == 1 && rows[0].cells.length == 1 && rows[0].cells[0].value == "" && normalized == "") {
      rows = [];
    }

    return Success(new CsvDocument(rows));
  }

  inline function error(message:String, line:Int, column:Int):FormatError {
    return new FormatError(FormatErrorCode.InvalidStructure, message, new FormatLocation(line, column), CsvFormat.id);
  }
}
