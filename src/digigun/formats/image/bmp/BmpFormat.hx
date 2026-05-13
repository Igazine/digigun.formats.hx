package digigun.formats.image.bmp;

import digigun.formats.FormatId;
import digigun.formats.MediaType;

/**
 * Shared metadata for the built-in BMP implementation.
 */
class BmpFormat {
  /** Stable identifier for the BMP format implementation. */
  public static final id:FormatId = new FormatId("bmp");
  /** Media type reported by the BMP format implementation. */
  public static final mediaType:MediaType = new MediaType("image/bmp");
}
