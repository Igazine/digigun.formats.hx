package digigun.formats.image.tiff;

import digigun.formats.FormatId;
import digigun.formats.MediaType;

/**
 * Shared metadata for the built-in TIFF implementation.
 */
class TiffFormat {
  /** Stable identifier for the TIFF format implementation. */
  public static final id:FormatId = new FormatId("tiff");
  /** Media type reported by the TIFF format implementation. */
  public static final mediaType:MediaType = new MediaType("image/tiff");
}
