package digigun.formats.image;

/**
 * Identifies a GPU-oriented texture compression method.
 */
enum abstract TextureCompressionMethod(String) from String to String {
  /** No GPU compression. */
  var None = "none";

  /** BC1 / DXT1 block compression. */
  var BC1 = "bc1";

  /** BC3 / DXT5 block compression. */
  var BC3 = "bc3";

  /** BC4 / RGTC1 block compression for single-channel textures. */
  var BC4 = "bc4";

  /** BC5 / RGTC2 block compression for two-channel textures. */
  var BC5 = "bc5";

  /** ETC2 RGB block compression. */
  var ETC2Rgb8 = "etc2-rgb8";

  /** ASTC 4x4 RGBA block compression. */
  var Astc4x4Rgba = "astc-4x4-rgba";

  /** PVRTC1 4bpp RGBA block compression. */
  var Pvrtc1_4Rgba = "pvrtc1-4-rgba";
}
