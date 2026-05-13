package digigun.formats.image.raw;

import digigun.formats.FormatId;
import digigun.formats.MediaType;

/**
 * Shared metadata for the built-in RAW bitmap implementation.
 */
class RawFormat {
  /** Stable identifier for the RAW image format implementation. */
  public static final id:FormatId = new FormatId("image-raw");
  /** Media type reported by the RAW image implementation. */
  public static final mediaType:MediaType = new MediaType("application/octet-stream");
}
