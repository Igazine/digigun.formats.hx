package digigun.formats.image;

import digigun.formats.FormatResult;
import haxe.io.Bytes;

/**
 * Basic pure-Haxe `BC4` block encoder for single-channel textures.
 */
class Bc4TextureBlockEncoder extends AbstractTextureBlockEncoder {
  public function new() {
    super(TextureCompressionMethod.BC4, PixelFormats.BC4_R_UNORM);
  }

  override public function canEncode(source:TextureData, options:TextureBlockEncodingOptions):Bool {
    if (!super.canEncode(source, options)) {
      return false;
    }

    if (source.format.isCompressed()) {
      return source.format.id == PixelFormats.BC4_R_UNORM.id;
    }

    return source.format.id == PixelFormats.R8_UNORM.id;
  }

  override function doEncode(source:TextureData, options:TextureBlockEncodingOptions):FormatResult<TextureBlockEncodingResult> {
    if (!canEncode(source, options)) {
      return Failure(error("BC4 encoding currently supports only R8 textures."));
    }

    var inputSurface = source.getPrimarySurface();
    if (inputSurface == null || inputSurface.mipLevels.length == 0) {
      return Failure(error("BC4 source texture has no mip levels."));
    }

    var order = source.format.channelOrder;
    if (order == null) {
      return Failure(error("BC4 source texture must expose channel ordering."));
    }

    var output = new TextureData(TextureDimension.Texture2D, source.size, PixelFormats.BC4_R_UNORM);
    var outputSurface = output.getOrCreatePrimarySurface();
    for (mip in inputSurface.mipLevels) {
      var encoded = RgtcTextureBlockEncoderSupport.encodeSingleChannelMipLevel(mip, order, 0);
      outputSurface.setMipLevel(new MipLevel(mip.level, mip.size, ByteBuffer.wrap(encoded)));
    }

    return Success(new TextureBlockEncodingResult(
      TextureCompressionMethod.BC4,
      output,
      false,
      "Encoded texture into BC4 blocks with the built-in baseline encoder."
    ));
  }
}
