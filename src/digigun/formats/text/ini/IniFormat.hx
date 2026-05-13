package digigun.formats.text.ini;

import digigun.formats.FormatId;
import digigun.formats.MediaType;

/**
 * Shared metadata for the built-in INI implementation.
 */
class IniFormat {
  /** Stable identifier for the INI format implementation. */
  public static final id:FormatId = new FormatId("ini");
  /** Media type reported by the INI format implementation. */
  public static final mediaType:MediaType = new MediaType("text/plain");
}
