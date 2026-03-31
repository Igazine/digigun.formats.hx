package digigun.formats.toml;

import digigun.formats.FormatId;
import digigun.formats.MediaType;

/**
 * Shared metadata for the built-in TOML implementation.
 */
class TomlFormat {
  /** Stable identifier for the TOML format implementation. */
  public static final id:FormatId = new FormatId("toml");
  /** Media type reported by the TOML format implementation. */
  public static final mediaType:MediaType = new MediaType("application/toml");
}
