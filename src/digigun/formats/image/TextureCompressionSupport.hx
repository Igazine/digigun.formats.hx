package digigun.formats.image;

/**
 * Compression-oriented planning helpers for future GPU texture encoders.
 */
class TextureCompressionSupport {
  /**
   * Returns compression metadata for a known built-in compressed format.
   */
  public static function infoForFormat(format:PixelFormat):Null<TextureCompressionInfo> {
    return switch (format.id) {
      case "bc1-rgb-unorm":
        new TextureCompressionInfo(TextureCompressionMethod.BC1, PixelFormats.BC1_RGB_UNORM, 4, 4, 8, "BC1 / DXT1 block compression for opaque RGB textures.");
      case "bc3-rgba-unorm":
        new TextureCompressionInfo(TextureCompressionMethod.BC3, PixelFormats.BC3_RGBA_UNORM, 4, 4, 16, "BC3 / DXT5 block compression with alpha support.");
      case "bc4-r-unorm":
        new TextureCompressionInfo(TextureCompressionMethod.BC4, PixelFormats.BC4_R_UNORM, 4, 4, 8, "BC4 / RGTC1 block compression for single-channel textures and masks.");
      case "bc5-rg-unorm":
        new TextureCompressionInfo(TextureCompressionMethod.BC5, PixelFormats.BC5_RG_UNORM, 4, 4, 16, "BC5 / RGTC2 block compression for dual-channel textures and normal maps.");
      case "etc2-rgb8-unorm":
        new TextureCompressionInfo(TextureCompressionMethod.ETC2Rgb8, PixelFormats.ETC2_RGB8_UNORM, 4, 4, 8, "ETC2 RGB block compression, especially relevant for OpenGL ES and WebGL 2.");
      case "etc2-rgba8-unorm":
        new TextureCompressionInfo(TextureCompressionMethod.ETC2Rgba8, PixelFormats.ETC2_RGBA8_UNORM, 4, 4, 16, "ETC2 RGBA block compression with separate alpha.");
      case "eac-r11-unorm":
        new TextureCompressionInfo(TextureCompressionMethod.EacR11, PixelFormats.EAC_R11_UNORM, 4, 4, 8, "EAC R11 block compression for single-channel textures and masks.");
      case "eac-rg11-unorm":
        new TextureCompressionInfo(TextureCompressionMethod.EacRg11, PixelFormats.EAC_RG11_UNORM, 4, 4, 16, "EAC RG11 block compression for dual-channel textures and vector maps.");
      case "astc-4x4-rgba-unorm":
        new TextureCompressionInfo(TextureCompressionMethod.Astc4x4Rgba, PixelFormats.ASTC_4X4_RGBA_UNORM, 4, 4, 16, "ASTC 4x4 RGBA block compression for modern mobile and desktop APIs.");
      case "pvrtc1-4-rgba-unorm":
        new TextureCompressionInfo(TextureCompressionMethod.Pvrtc1_4Rgba, PixelFormats.PVRTC1_4_RGBA_UNORM, 4, 4, 8, "PVRTC1 4bpp RGBA compression for PowerVR-style targets.");
      default:
        null;
    };
  }

  /**
   * Returns the built-in compressed output format for a method.
   */
  public static function formatForMethod(method:TextureCompressionMethod):PixelFormat {
    return switch (method) {
      case TextureCompressionMethod.BC1:
        PixelFormats.BC1_RGB_UNORM;
      case TextureCompressionMethod.BC3:
        PixelFormats.BC3_RGBA_UNORM;
      case TextureCompressionMethod.BC4:
        PixelFormats.BC4_R_UNORM;
      case TextureCompressionMethod.BC5:
        PixelFormats.BC5_RG_UNORM;
      case TextureCompressionMethod.ETC2Rgb8:
        PixelFormats.ETC2_RGB8_UNORM;
      case TextureCompressionMethod.ETC2Rgba8:
        PixelFormats.ETC2_RGBA8_UNORM;
      case TextureCompressionMethod.EacR11:
        PixelFormats.EAC_R11_UNORM;
      case TextureCompressionMethod.EacRg11:
        PixelFormats.EAC_RG11_UNORM;
      case TextureCompressionMethod.Astc4x4Rgba:
        PixelFormats.ASTC_4X4_RGBA_UNORM;
      case TextureCompressionMethod.Pvrtc1_4Rgba:
        PixelFormats.PVRTC1_4_RGBA_UNORM;
      case TextureCompressionMethod.None:
        PixelFormats.RGBA8_UNORM;
      default:
        PixelFormats.RGBA8_UNORM;
    };
  }

  /**
   * Returns a practical container profile for a built-in texture container.
   */
  public static function containerProfile(container:TextureContainerFormat):TextureContainerProfile {
    return switch (container) {
      case TextureContainerFormat.Raw:
        new TextureContainerProfile(container, true, true, [
          PixelFormats.R8_UNORM.id,
          PixelFormats.RG8_UNORM.id,
          PixelFormats.RGB8_UNORM.id,
          PixelFormats.RGBA8_UNORM.id,
          PixelFormats.BC1_RGB_UNORM.id,
          PixelFormats.BC3_RGBA_UNORM.id,
          PixelFormats.BC4_R_UNORM.id,
          PixelFormats.BC5_RG_UNORM.id,
          PixelFormats.ETC2_RGB8_UNORM.id,
          PixelFormats.ETC2_RGBA8_UNORM.id,
          PixelFormats.EAC_R11_UNORM.id,
          PixelFormats.EAC_RG11_UNORM.id,
          PixelFormats.ASTC_4X4_RGBA_UNORM.id,
          PixelFormats.PVRTC1_4_RGBA_UNORM.id
        ]);
      case TextureContainerFormat.Dds:
        new TextureContainerProfile(container, true, true, [
          PixelFormats.BGR8_UNORM.id,
          PixelFormats.BGRA8_UNORM.id,
          PixelFormats.BC1_RGB_UNORM.id,
          PixelFormats.BC3_RGBA_UNORM.id,
          PixelFormats.BC4_R_UNORM.id,
          PixelFormats.BC5_RG_UNORM.id
        ]);
      case TextureContainerFormat.Ktx:
        new TextureContainerProfile(container, true, true, [
          PixelFormats.RG8_UNORM.id,
          PixelFormats.RGB8_UNORM.id,
          PixelFormats.RGBA8_UNORM.id,
          PixelFormats.BC1_RGB_UNORM.id,
          PixelFormats.BC3_RGBA_UNORM.id,
          PixelFormats.BC4_R_UNORM.id,
          PixelFormats.BC5_RG_UNORM.id,
          PixelFormats.ETC2_RGB8_UNORM.id,
          PixelFormats.ETC2_RGBA8_UNORM.id,
          PixelFormats.EAC_R11_UNORM.id,
          PixelFormats.EAC_RG11_UNORM.id,
          PixelFormats.ASTC_4X4_RGBA_UNORM.id
        ]);
      case TextureContainerFormat.Pvr:
        new TextureContainerProfile(container, true, true, [
          PixelFormats.PVRTC1_4_RGBA_UNORM.id
        ]);
      default:
        new TextureContainerProfile(container, false, false, []);
    };
  }

  /**
   * Builds a future-facing encode/transcode plan for a target API family.
   */
  public static function buildPlan(request:TextureEncodingRequest):TextureTranscodePlan {
    var baseline = TextureFormatSupport.recommendCompression(request.api);
    var container = request.preferredContainer == null ? baseline.container : request.preferredContainer;

    var profile = containerProfile(container);
    var compressedFormat = chooseCompressedFormat(request, container, baseline.format);
    if (compressedFormat != null) {
      var info = infoForFormat(compressedFormat);
      return new TextureTranscodePlan(request, container, compressedFormat, info.method, true, baseline.reason);
    }

    if (!request.allowUncompressedFallback) {
      var baselineInfo = infoForFormat(baseline.format);
      return new TextureTranscodePlan(
        request,
        baseline.container,
        baseline.format,
        baselineInfo == null ? TextureCompressionMethod.None : baselineInfo.method,
        baselineInfo != null,
        "Falling back to the API-default compressed container because the preferred container has no compatible built-in compressed format."
      );
    }

    var fallbackFormat = chooseUncompressedFallback(request.source.format);
    return new TextureTranscodePlan(
      request,
      container,
      fallbackFormat,
      TextureCompressionMethod.None,
      false,
      "Falling back to an uncompressed texture layout because the requested container/target combination has no built-in compressed match."
    );
  }

  static function chooseCompressedFormat(request:TextureEncodingRequest, container:TextureContainerFormat, baseline:PixelFormat):Null<PixelFormat> {
    var sourceHasAlpha = request.source.format.channelOrder != null && request.source.format.channelOrder.hasAlpha();
    var sourceOrder = request.source.format.channelOrder;
    var preferSingleChannel = sourceOrder == ChannelOrder.R;
    var preferDualChannel = sourceOrder == ChannelOrder.RG;
    var profile = containerProfile(container);
    var candidates = candidateFormatsForApi(request.api, request.requireAlpha || sourceHasAlpha);
    if (request.requireAlpha && sourceHasAlpha) {
      reorderCandidate(candidates, PixelFormats.ETC2_RGBA8_UNORM);
    } else if (!request.requireAlpha && preferSingleChannel) {
      reorderCandidate(candidates, request.api == GraphicsApi.Direct3D11 ? PixelFormats.BC4_R_UNORM : PixelFormats.EAC_R11_UNORM);
    } else if (!request.requireAlpha && preferDualChannel) {
      reorderCandidate(candidates, request.api == GraphicsApi.Direct3D11 ? PixelFormats.BC5_RG_UNORM : PixelFormats.EAC_RG11_UNORM);
    } else if (!request.requireAlpha && !sourceHasAlpha) {
      reorderCandidate(candidates, PixelFormats.ETC2_RGB8_UNORM);
    }
    if ((request.requireAlpha || sourceHasAlpha) && baseline.id == PixelFormats.BC3_RGBA_UNORM.id && candidates.indexOf(PixelFormats.BC3_RGBA_UNORM) < 0) {
      candidates.unshift(PixelFormats.BC3_RGBA_UNORM);
    } else if (!request.requireAlpha && !sourceHasAlpha && !preferSingleChannel && !preferDualChannel) {
      if (candidates.indexOf(PixelFormats.BC1_RGB_UNORM) < 0) {
        candidates.unshift(PixelFormats.BC1_RGB_UNORM);
      }
    }

    for (candidate in candidates) {
      if (profile.supportedFormatIds.indexOf(candidate.id) >= 0 && TextureFormatSupport.canUpload(request.api, candidate)) {
        return candidate;
      }
    }

    if (profile.supportedFormatIds.indexOf(baseline.id) >= 0 && TextureFormatSupport.canUpload(request.api, baseline)) {
      return baseline;
    }

    return null;
  }

  static function reorderCandidate(candidates:Array<PixelFormat>, preferred:PixelFormat):Void {
    var index = candidates.indexOf(preferred);
    if (index >= 0) {
      candidates.splice(index, 1);
    }
    candidates.unshift(preferred);
  }

  static function chooseUncompressedFallback(sourceFormat:PixelFormat):PixelFormat {
    if (sourceFormat.channelOrder == ChannelOrder.R) {
      return PixelFormats.R8_UNORM;
    }

    if (sourceFormat.channelOrder == ChannelOrder.RG) {
      return PixelFormats.RG8_UNORM;
    }

    if (sourceFormat.channelOrder != null && sourceFormat.channelOrder.hasAlpha()) {
      return sourceFormat.colorSpace == ColorSpace.SRgb ? PixelFormats.RGBA8_SRGB : PixelFormats.RGBA8_UNORM;
    }

    return PixelFormats.RGB8_UNORM;
  }

  static function candidateFormatsForApi(api:GraphicsApi, needAlpha:Bool):Array<PixelFormat> {
    return switch (api) {
      case GraphicsApi.OpenGL:
        needAlpha
          ? [PixelFormats.ETC2_RGBA8_UNORM, PixelFormats.BC3_RGBA_UNORM, PixelFormats.ASTC_4X4_RGBA_UNORM]
          : [PixelFormats.ETC2_RGB8_UNORM, PixelFormats.EAC_R11_UNORM, PixelFormats.EAC_RG11_UNORM, PixelFormats.BC1_RGB_UNORM];
      case GraphicsApi.WebGL:
        needAlpha
          ? [PixelFormats.ETC2_RGBA8_UNORM, PixelFormats.ASTC_4X4_RGBA_UNORM, PixelFormats.BC3_RGBA_UNORM]
          : [PixelFormats.ETC2_RGB8_UNORM, PixelFormats.EAC_R11_UNORM, PixelFormats.EAC_RG11_UNORM, PixelFormats.BC1_RGB_UNORM];
      case GraphicsApi.Vulkan:
        needAlpha
          ? [PixelFormats.ETC2_RGBA8_UNORM, PixelFormats.ASTC_4X4_RGBA_UNORM, PixelFormats.BC3_RGBA_UNORM]
          : [PixelFormats.ETC2_RGB8_UNORM, PixelFormats.EAC_R11_UNORM, PixelFormats.EAC_RG11_UNORM, PixelFormats.ASTC_4X4_RGBA_UNORM, PixelFormats.BC5_RG_UNORM, PixelFormats.BC1_RGB_UNORM];
      case GraphicsApi.Metal:
        needAlpha
          ? [PixelFormats.ASTC_4X4_RGBA_UNORM, PixelFormats.PVRTC1_4_RGBA_UNORM, PixelFormats.BC3_RGBA_UNORM]
          : [PixelFormats.ASTC_4X4_RGBA_UNORM, PixelFormats.PVRTC1_4_RGBA_UNORM, PixelFormats.BC1_RGB_UNORM];
      case GraphicsApi.Direct3D11:
        needAlpha
          ? [PixelFormats.BC3_RGBA_UNORM]
          : [PixelFormats.BC1_RGB_UNORM, PixelFormats.BC4_R_UNORM, PixelFormats.BC5_RG_UNORM];
      default:
        [];
    };
  }
}
