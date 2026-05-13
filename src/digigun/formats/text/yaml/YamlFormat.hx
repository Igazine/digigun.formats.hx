package digigun.formats.text.yaml;

import digigun.formats.FormatId;
import digigun.formats.MediaType;

/**
 * Shared metadata for the built-in YAML implementation.
 */
class YamlFormat {
  /** Stable identifier for the YAML format implementation. */
  public static final id:FormatId = new FormatId("yaml");
  /** Media type reported by the YAML format implementation. */
  public static final mediaType:MediaType = new MediaType("application/yaml");
}

