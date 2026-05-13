package digigun.formats.image;

import digigun.formats.FormatError;
import digigun.formats.FormatErrorCode;
import digigun.formats.FormatResult;

/**
 * Registry and dispatch helpers for future GPU block encoders.
 */
class TextureBlockEncodingSupport {
  /**
   * Creates a built-in encoder for a compression method.
   */
  public static function createEncoder(method:TextureCompressionMethod):TextureBlockEncoder {
    return switch (method) {
      case TextureCompressionMethod.BC1:
        new Bc1TextureBlockEncoder();
      case TextureCompressionMethod.BC3:
        new Bc3TextureBlockEncoder();
      case TextureCompressionMethod.BC4:
        new Bc4TextureBlockEncoder();
      case TextureCompressionMethod.BC5:
        new Bc5TextureBlockEncoder();
      case TextureCompressionMethod.ETC2Rgb8:
        new Etc2Rgb8TextureBlockEncoder();
      case TextureCompressionMethod.Astc4x4Rgba:
        new Astc4x4RgbaTextureBlockEncoder();
      case TextureCompressionMethod.Pvrtc1_4Rgba:
        new Pvrtc1_4RgbaTextureBlockEncoder();
      case TextureCompressionMethod.None:
        null;
      default:
        null;
    };
  }

  /**
   * Creates a built-in encoder based on a compressed output format.
   */
  public static function createEncoderForFormat(format:PixelFormat):Null<TextureBlockEncoder> {
    var info = TextureCompressionSupport.infoForFormat(format);
    return info == null ? null : createEncoder(info.method);
  }

  /**
   * Builds a transcode plan and routes it into the matching encoder.
   */
  public static function encode(request:TextureEncodingRequest, options:TextureBlockEncodingOptions):FormatResult<TextureBlockEncodingResult> {
    var plan = TextureCompressionSupport.buildPlan(request);
    if (plan.compressionMethod == TextureCompressionMethod.None) {
      return Failure(new FormatError(
        FormatErrorCode.UnsupportedFeature,
        "The planned output is uncompressed, so no GPU block encoder is required."
      ));
    }

    var encoder = createEncoder(plan.compressionMethod);
    if (encoder == null) {
      return Failure(new FormatError(
        FormatErrorCode.UnsupportedFeature,
        'No built-in encoder is registered for ${plan.compressionMethod}.'
      ));
    }

    return encoder.encode(request.source, options);
  }
}
