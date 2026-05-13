package digigun.formats.image;

import digigun.formats.FormatResult;
import haxe.io.Bytes;

/**
 * Basic pure-Haxe `BC5` block encoder for dual-channel textures.
 */
class Bc5TextureBlockEncoder extends AbstractTextureBlockEncoder {
  public function new() {
    super(TextureCompressionMethod.BC5, PixelFormats.BC5_RG_UNORM);
  }

  override public function canEncode(source:TextureData, options:TextureBlockEncodingOptions):Bool {
    if (!super.canEncode(source, options)) {
      return false;
    }

    if (source.format.isCompressed()) {
      return source.format.id == PixelFormats.BC5_RG_UNORM.id;
    }

    return source.format.id == PixelFormats.RG8_UNORM.id;
  }

  override function doEncode(source:TextureData, options:TextureBlockEncodingOptions):FormatResult<TextureBlockEncodingResult> {
    if (!canEncode(source, options)) {
      return Failure(error("BC5 encoding currently supports only RG8 textures."));
    }

    var inputSurface = source.getPrimarySurface();
    if (inputSurface == null || inputSurface.mipLevels.length == 0) {
      return Failure(error("BC5 source texture has no mip levels."));
    }

    var order = source.format.channelOrder;
    if (order == null) {
      return Failure(error("BC5 source texture must expose channel ordering."));
    }

    var output = new TextureData(TextureDimension.Texture2D, source.size, PixelFormats.BC5_RG_UNORM);
    var outputSurface = output.getOrCreatePrimarySurface();
    for (mip in inputSurface.mipLevels) {
      var encoded = RgtcTextureBlockEncoderSupport.encodeDualChannelMipLevel(mip, order);
      outputSurface.setMipLevel(new MipLevel(mip.level, mip.size, ByteBuffer.wrap(encoded)));
    }

    return Success(new TextureBlockEncodingResult(
      TextureCompressionMethod.BC5,
      output,
      false,
      "Encoded texture into BC5 blocks with the built-in baseline encoder."
    ));
  }
}
