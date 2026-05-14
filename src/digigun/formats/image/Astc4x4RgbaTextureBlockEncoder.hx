package digigun.formats.image;

/**
 * Deferred `ASTC 4x4 RGBA` encoder placeholder.
 *
 * The library keeps this type so passthrough and planning code can model ASTC
 * targets cleanly, but fresh built-in ASTC encoding is still deferred.
 */
class Astc4x4RgbaTextureBlockEncoder extends AbstractTextureBlockEncoder {
  public function new() {
    super(TextureCompressionMethod.Astc4x4Rgba, PixelFormats.ASTC_4X4_RGBA_UNORM);
  }
}
