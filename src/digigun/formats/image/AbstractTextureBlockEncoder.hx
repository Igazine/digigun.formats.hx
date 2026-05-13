package digigun.formats.image;

import digigun.formats.FormatError;
import digigun.formats.FormatErrorCode;
import digigun.formats.FormatResult;

/**
 * Shared base class for future GPU block encoder implementations.
 *
 * This base class already handles safe passthrough when the source texture is
 * already in the target compressed format. Real encoders can later override
 * `doEncode` to implement block compression.
 */
class AbstractTextureBlockEncoder implements TextureBlockEncoder {
  public var method(get, never):TextureCompressionMethod;
  public var outputFormat(get, never):PixelFormat;

  final compressionMethod:TextureCompressionMethod;
  final compressionOutputFormat:PixelFormat;

  /**
   * Creates a new encoder base with one target output format.
   */
  public function new(method:TextureCompressionMethod, outputFormat:PixelFormat) {
    this.compressionMethod = method;
    this.compressionOutputFormat = outputFormat;
  }

  public function get_method():TextureCompressionMethod {
    return compressionMethod;
  }

  public function get_outputFormat():PixelFormat {
    return compressionOutputFormat;
  }

  public function canEncode(source:TextureData, options:TextureBlockEncodingOptions):Bool {
    return source.dimension == TextureDimension.Texture2D;
  }

  public function encode(source:TextureData, options:TextureBlockEncodingOptions):FormatResult<TextureBlockEncodingResult> {
    if (!canEncode(source, options)) {
      return Failure(error("Only 2D textures are currently supported by the block-encoder pipeline."));
    }

    if (options.allowPassthrough && source.format.id == compressionOutputFormat.id) {
      return Success(new TextureBlockEncodingResult(
        compressionMethod,
        source,
        true,
        "Source texture already matches the requested GPU-compressed output format."
      ));
    }

    return doEncode(source, options);
  }

  /**
   * Performs actual encoding work in concrete subclasses.
   */
  function doEncode(source:TextureData, options:TextureBlockEncodingOptions):FormatResult<TextureBlockEncodingResult> {
    return Failure(error('GPU block encoding for ${compressionMethod} is not implemented yet.'));
  }

  function error(message:String):FormatError {
    return new FormatError(FormatErrorCode.UnsupportedFeature, message);
  }
}
