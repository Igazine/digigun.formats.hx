package digigun.formats.image;

/**
 * Centralized upload-compatibility and compression recommendations for
 * GPU-facing texture formats.
 */
class TextureFormatSupport {
  /**
   * Returns true when a pixel format is a reasonable built-in target for the
   * given graphics API family.
   */
  public static function canUpload(api:GraphicsApi, format:PixelFormat):Bool {
    if (!format.isCompressed()) {
      return switch (api) {
        case GraphicsApi.OpenGL, GraphicsApi.WebGL, GraphicsApi.Vulkan, GraphicsApi.Metal, GraphicsApi.Direct3D11:
          isCommonUncompressed(format);
        default:
          false;
      };
    }

    return switch (api) {
      case GraphicsApi.OpenGL:
        format.id == PixelFormats.BC1_RGB_UNORM.id
          || format.id == PixelFormats.BC4_R_UNORM.id
          || format.id == PixelFormats.BC3_RGBA_UNORM.id
          || format.id == PixelFormats.BC5_RG_UNORM.id
          || format.id == PixelFormats.ETC2_RGB8_UNORM.id
          || format.id == PixelFormats.ASTC_4X4_RGBA_UNORM.id;
      case GraphicsApi.WebGL:
        format.id == PixelFormats.ETC2_RGB8_UNORM.id
          || format.id == PixelFormats.ASTC_4X4_RGBA_UNORM.id
          || format.id == PixelFormats.BC1_RGB_UNORM.id
          || format.id == PixelFormats.BC3_RGBA_UNORM.id;
      case GraphicsApi.Vulkan:
        format.id == PixelFormats.BC1_RGB_UNORM.id
          || format.id == PixelFormats.BC4_R_UNORM.id
          || format.id == PixelFormats.BC3_RGBA_UNORM.id
          || format.id == PixelFormats.BC5_RG_UNORM.id
          || format.id == PixelFormats.ETC2_RGB8_UNORM.id
          || format.id == PixelFormats.ASTC_4X4_RGBA_UNORM.id;
      case GraphicsApi.Metal:
        format.id == PixelFormats.BC1_RGB_UNORM.id
          || format.id == PixelFormats.BC3_RGBA_UNORM.id
          || format.id == PixelFormats.ASTC_4X4_RGBA_UNORM.id
          || format.id == PixelFormats.PVRTC1_4_RGBA_UNORM.id;
      case GraphicsApi.Direct3D11:
        format.id == PixelFormats.BC1_RGB_UNORM.id
          || format.id == PixelFormats.BC3_RGBA_UNORM.id
          || format.id == PixelFormats.BC4_R_UNORM.id
          || format.id == PixelFormats.BC5_RG_UNORM.id;
      default:
        false;
    };
  }

  /**
   * Returns a preferred compressed texture format and container for a target
   * API family.
   */
  public static function recommendCompression(api:GraphicsApi):TextureCompressionPlan {
    return switch (api) {
      case GraphicsApi.OpenGL:
        new TextureCompressionPlan(api, PixelFormats.BC3_RGBA_UNORM, TextureContainerFormat.Dds, "BC formats are broadly practical on desktop OpenGL workflows.");
      case GraphicsApi.WebGL:
        new TextureCompressionPlan(api, PixelFormats.ETC2_RGB8_UNORM, TextureContainerFormat.Ktx, "ETC2 has strong WebGL 2 alignment and KTX is a natural container.");
      case GraphicsApi.Vulkan:
        new TextureCompressionPlan(api, PixelFormats.ASTC_4X4_RGBA_UNORM, TextureContainerFormat.Ktx, "ASTC is a strong general-purpose Vulkan target and KTX is the most natural Khronos container.");
      case GraphicsApi.Metal:
        new TextureCompressionPlan(api, PixelFormats.ASTC_4X4_RGBA_UNORM, TextureContainerFormat.Ktx, "ASTC is the preferred modern Apple GPU compression family.");
      case GraphicsApi.Direct3D11:
        new TextureCompressionPlan(api, PixelFormats.BC3_RGBA_UNORM, TextureContainerFormat.Dds, "BC-compressed DDS assets fit the Direct3D-style pipeline well.");
      default:
        new TextureCompressionPlan(api, PixelFormats.RGBA8_UNORM, TextureContainerFormat.Raw, "Fallback to uncompressed RGBA8 when no API-specific compressed target is known.");
    };
  }

  static function isCommonUncompressed(format:PixelFormat):Bool {
    return format.id == PixelFormats.R8_UNORM.id
      || format.id == PixelFormats.RG8_UNORM.id
      || format.id == PixelFormats.RGB8_UNORM.id
      || format.id == PixelFormats.BGR8_UNORM.id
      || format.id == PixelFormats.RGBA8_UNORM.id
      || format.id == PixelFormats.BGRA8_UNORM.id
      || format.id == PixelFormats.RGBA16_FLOAT.id
      || format.id == PixelFormats.RGBA32_FLOAT.id;
  }
}
