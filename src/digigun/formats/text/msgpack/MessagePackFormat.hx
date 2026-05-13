package digigun.formats.text.msgpack;

import digigun.formats.FormatId;
import digigun.formats.MediaType;

/**
 * Shared metadata for the built-in MessagePack implementation.
 */
class MessagePackFormat {
  /** Stable identifier for the MessagePack format implementation. */
  public static final id:FormatId = new FormatId("msgpack");
  /** Media type reported by the MessagePack format implementation. */
  public static final mediaType:MediaType = new MediaType("application/msgpack");
}

