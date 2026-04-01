package digigun.formats.ndjson;

import digigun.formats.FormatId;
import digigun.formats.MediaType;

/**
 * Shared metadata for the built-in NDJSON implementation.
 */
class NdjsonFormat {
  /** Stable identifier for the NDJSON format implementation. */
  public static final id:FormatId = new FormatId("ndjson");
  /** Media type reported by the NDJSON format implementation. */
  public static final mediaType:MediaType = new MediaType("application/x-ndjson");
}

