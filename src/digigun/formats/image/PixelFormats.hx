package digigun.formats.image;

/**
 * Common uncompressed and GPU-compressed texture format descriptors.
 */
class PixelFormats {
  /** 8-bit normalized single-channel pixels in linear space. */
  public static final R8_UNORM = new PixelFormat("r8-unorm", ChannelOrder.R, ChannelType.Unorm8);

  /** 8-bit normalized BGR pixels in linear space. */
  public static final BGR8_UNORM = new PixelFormat("bgr8-unorm", ChannelOrder.BGR, ChannelType.Unorm8);

  /** 8-bit normalized RGB pixels in linear space. */
  public static final RGB8_UNORM = new PixelFormat("rgb8-unorm", ChannelOrder.RGB, ChannelType.Unorm8);

  /** 8-bit normalized RGBA pixels in linear space. */
  public static final RGBA8_UNORM = new PixelFormat("rgba8-unorm", ChannelOrder.RGBA, ChannelType.Unorm8);

  /** 8-bit normalized BGRA pixels in linear space. */
  public static final BGRA8_UNORM = new PixelFormat("bgra8-unorm", ChannelOrder.BGRA, ChannelType.Unorm8);

  /** 8-bit normalized RG pixels in linear space. */
  public static final RG8_UNORM = new PixelFormat("rg8-unorm", ChannelOrder.RG, ChannelType.Unorm8);

  /** 8-bit normalized RGBA pixels in sRGB space. */
  public static final RGBA8_SRGB = new PixelFormat("rgba8-srgb", ChannelOrder.RGBA, ChannelType.Unorm8, ColorSpace.SRgb);

  /** 16-bit floating-point RGBA pixels in linear space. */
  public static final RGBA16_FLOAT = new PixelFormat("rgba16-float", ChannelOrder.RGBA, ChannelType.Float16);

  /** 32-bit floating-point RGBA pixels in linear space. */
  public static final RGBA32_FLOAT = new PixelFormat("rgba32-float", ChannelOrder.RGBA, ChannelType.Float32);

  /** BC1 / DXT1 style compressed RGB data. */
  public static final BC1_RGB_UNORM = new PixelFormat("bc1-rgb-unorm", null, null, ColorSpace.Linear, CompressedFormatFamily.BC, 4, 4, 8);

  /** BC3 / DXT5 style compressed RGBA data. */
  public static final BC3_RGBA_UNORM = new PixelFormat("bc3-rgba-unorm", null, null, ColorSpace.Linear, CompressedFormatFamily.BC, 4, 4, 16);

  /** BC4 / RGTC1 style compressed single-channel data. */
  public static final BC4_R_UNORM = new PixelFormat("bc4-r-unorm", null, null, ColorSpace.Linear, CompressedFormatFamily.BC, 4, 4, 8);

  /** BC5 / RGTC2 style compressed two-channel data. */
  public static final BC5_RG_UNORM = new PixelFormat("bc5-rg-unorm", null, null, ColorSpace.Linear, CompressedFormatFamily.BC, 4, 4, 16);

  /** ETC2 compressed RGB data. */
  public static final ETC2_RGB8_UNORM = new PixelFormat("etc2-rgb8-unorm", null, null, ColorSpace.Linear, CompressedFormatFamily.ETC2, 4, 4, 8);

  /** ETC2 compressed RGBA data with separate alpha. */
  public static final ETC2_RGBA8_UNORM = new PixelFormat("etc2-rgba8-unorm", null, null, ColorSpace.Linear, CompressedFormatFamily.ETC2, 4, 4, 16);

  /** EAC compressed single-channel data. */
  public static final EAC_R11_UNORM = new PixelFormat("eac-r11-unorm", null, null, ColorSpace.Linear, CompressedFormatFamily.ETC2, 4, 4, 8);

  /** EAC compressed dual-channel data. */
  public static final EAC_RG11_UNORM = new PixelFormat("eac-rg11-unorm", null, null, ColorSpace.Linear, CompressedFormatFamily.ETC2, 4, 4, 16);

  /** ASTC 4x4 compressed RGBA data. */
  public static final ASTC_4X4_RGBA_UNORM = new PixelFormat("astc-4x4-rgba-unorm", null, null, ColorSpace.Linear, CompressedFormatFamily.ASTC, 4, 4, 16);

  /** PVRTC1 4bpp RGBA compressed data. */
  public static final PVRTC1_4_RGBA_UNORM = new PixelFormat("pvrtc1-4-rgba-unorm", null, null, ColorSpace.Linear, CompressedFormatFamily.PVRTC, 4, 4, 8);

  /**
   * Looks up a common pixel format by identifier.
   */
  public static function byId(id:String):Null<PixelFormat> {
    return switch (id) {
      case "r8-unorm":
        R8_UNORM;
      case "rgb8-unorm":
        RGB8_UNORM;
      case "bgr8-unorm":
        BGR8_UNORM;
      case "rgba8-unorm":
        RGBA8_UNORM;
      case "bgra8-unorm":
        BGRA8_UNORM;
      case "rg8-unorm":
        RG8_UNORM;
      case "rgba8-srgb":
        RGBA8_SRGB;
      case "rgba16-float":
        RGBA16_FLOAT;
      case "rgba32-float":
        RGBA32_FLOAT;
      case "bc1-rgb-unorm":
        BC1_RGB_UNORM;
      case "bc3-rgba-unorm":
        BC3_RGBA_UNORM;
      case "bc4-r-unorm":
        BC4_R_UNORM;
      case "bc5-rg-unorm":
        BC5_RG_UNORM;
      case "etc2-rgb8-unorm":
        ETC2_RGB8_UNORM;
      case "etc2-rgba8-unorm":
        ETC2_RGBA8_UNORM;
      case "eac-r11-unorm":
        EAC_R11_UNORM;
      case "eac-rg11-unorm":
        EAC_RG11_UNORM;
      case "astc-4x4-rgba-unorm":
        ASTC_4X4_RGBA_UNORM;
      case "pvrtc1-4-rgba-unorm":
        PVRTC1_4_RGBA_UNORM;
      default:
        null;
    };
  }
}
