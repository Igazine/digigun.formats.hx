package digigun.formats.image;

/**
 * Future `PVRTC1 4bpp RGBA` block encoder.
 */
class Pvrtc1_4RgbaTextureBlockEncoder extends AbstractTextureBlockEncoder {
  public function new() {
    super(TextureCompressionMethod.Pvrtc1_4Rgba, PixelFormats.PVRTC1_4_RGBA_UNORM);
  }
}
