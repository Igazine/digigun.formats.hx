package digigun.formats.image;

/**
 * Deferred `PVRTC1 4bpp RGBA` encoder placeholder.
 *
 * The library keeps this type so passthrough and planning code can model PVRTC
 * targets cleanly, but fresh built-in PVRTC encoding is still deferred.
 */
class Pvrtc1_4RgbaTextureBlockEncoder extends AbstractTextureBlockEncoder {
  public function new() {
    super(TextureCompressionMethod.Pvrtc1_4Rgba, PixelFormats.PVRTC1_4_RGBA_UNORM);
  }
}
