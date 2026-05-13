package digigun.formats.image;

/**
 * Defines the transfer/color space interpretation of pixel data.
 */
enum abstract ColorSpace(String) from String to String {
  /** Linear color space. */
  var Linear = "linear";

  /** Standard RGB transfer function. */
  var SRgb = "srgb";
}
