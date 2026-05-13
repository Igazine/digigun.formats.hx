package digigun.formats.text.properties;

import digigun.formats.FormatId;
import digigun.formats.MediaType;

/**
 * Shared metadata for the built-in `.properties` implementation.
 */
class PropertiesFormat {
  /** Stable identifier for the properties format implementation. */
  public static final id:FormatId = new FormatId("properties");
  /** Media type reported by the properties format implementation. */
  public static final mediaType:MediaType = new MediaType("text/plain");
}

