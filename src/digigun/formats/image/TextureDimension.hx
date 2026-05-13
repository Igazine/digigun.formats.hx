package digigun.formats.image;

/**
 * Describes the logical shape of a texture.
 */
enum abstract TextureDimension(String) from String to String {
  /** One 2D image. */
  var Texture2D = "2d";

  /** A volume texture with depth. */
  var Texture3D = "3d";

  /** A cube texture with up to six faces per layer. */
  var Cube = "cube";
}
