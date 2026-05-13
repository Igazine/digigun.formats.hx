package digigun.formats.image.dds;

import digigun.formats.FormatId;
import digigun.formats.MediaType;

/**
 * Shared metadata for the built-in DDS implementation.
 */
class DdsFormat {
  public static final id:FormatId = new FormatId("dds");
  public static final mediaType:MediaType = new MediaType("image/vnd-ms.dds");
}
