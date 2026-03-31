package digigun.formats.env;

import digigun.formats.FormatId;
import digigun.formats.MediaType;

/**
 * Shared metadata for the built-in `.env` implementation.
 */
class EnvFormat {
  /** Stable identifier for the env format implementation. */
  public static final id:FormatId = new FormatId("env");
  /** Media type reported by the env format implementation. */
  public static final mediaType:MediaType = new MediaType("text/plain");
}

