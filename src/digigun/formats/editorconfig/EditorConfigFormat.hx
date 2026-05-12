package digigun.formats.editorconfig;

import digigun.formats.FormatId;
import digigun.formats.MediaType;

/**
 * Shared metadata for the built-in EditorConfig implementation.
 */
class EditorConfigFormat {
  /** Stable identifier for the EditorConfig format implementation. */
  public static final id:FormatId = new FormatId("editorconfig");
  /** Media type reported by the EditorConfig format implementation. */
  public static final mediaType:MediaType = new MediaType("text/plain");
}
