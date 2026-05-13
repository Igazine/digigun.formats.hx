package digigun.formats.image;

/**
 * Groups related block-compressed GPU texture formats.
 */
enum abstract CompressedFormatFamily(String) from String to String {
  /** DirectX block compression, also known as BCn / S3TC variants. */
  var BC = "bc";

  /** Ericsson Texture Compression version 2. */
  var ETC2 = "etc2";

  /** Adaptive Scalable Texture Compression. */
  var ASTC = "astc";

  /** PowerVR texture compression. */
  var PVRTC = "pvrtc";
}
