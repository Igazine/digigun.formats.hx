package digigun.formats.image;

/**
 * Identifies a texture-oriented container format.
 */
enum abstract TextureContainerFormat(String) from String to String {
  /** Headerless bitmap payload with external metadata. */
  var Raw = "raw";

  /** DirectDraw Surface container. */
  var Dds = "dds";

  /** Khronos texture container v1. */
  var Ktx = "ktx";

  /** PowerVR texture container. */
  var Pvr = "pvr";
}
