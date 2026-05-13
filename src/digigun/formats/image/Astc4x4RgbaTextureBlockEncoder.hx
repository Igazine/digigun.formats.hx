package digigun.formats.image;

/**
 * Future `ASTC 4x4 RGBA` block encoder.
 */
class Astc4x4RgbaTextureBlockEncoder extends AbstractTextureBlockEncoder {
  public function new() {
    super(TextureCompressionMethod.Astc4x4Rgba, PixelFormats.ASTC_4X4_RGBA_UNORM);
  }
}
