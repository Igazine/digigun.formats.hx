package digigun.formats.text.hcl;

import digigun.formats.FormatId;
import digigun.formats.MediaType;

/**
 * Shared metadata for the built-in HCL2 implementation.
 */
class HclFormat {
  /** Stable identifier for the HCL2 format implementation. */
  public static final id:FormatId = new FormatId("hcl2");
  /** Media type reported by the HCL2 format implementation. */
  public static final mediaType:MediaType = new MediaType("application/hcl");
}

