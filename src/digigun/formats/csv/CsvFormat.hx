package digigun.formats.csv;

import digigun.formats.FormatId;
import digigun.formats.MediaType;

/**
 * Shared metadata for the built-in CSV implementation.
 */
class CsvFormat {
  /** Stable identifier for the CSV format implementation. */
  public static final id:FormatId = new FormatId("csv");
  /** Media type reported by the CSV format implementation. */
  public static final mediaType:MediaType = new MediaType("text/csv");
}

