package digigun.formats.image;

import digigun.formats.FormatResult;

/**
 * Basic pure-Haxe `EAC R11` block encoder for single-channel textures.
 */
class EacR11TextureBlockEncoder extends AbstractTextureBlockEncoder {
  public function new() {
    super(TextureCompressionMethod.EacR11, PixelFormats.EAC_R11_UNORM);
  }

  override public function canEncode(source:TextureData, options:TextureBlockEncodingOptions):Bool {
    if (!super.canEncode(source, options)) {
      return false;
    }

    if (source.format.isCompressed()) {
      return source.format.id == PixelFormats.EAC_R11_UNORM.id;
    }

    return source.format.id == PixelFormats.R8_UNORM.id;
  }

  override function doEncode(source:TextureData, options:TextureBlockEncodingOptions):FormatResult<TextureBlockEncodingResult> {
    if (!canEncode(source, options)) {
      return Failure(error("EAC R11 encoding currently supports only R8 textures."));
    }

    var inputSurface = source.getPrimarySurface();
    if (inputSurface == null || inputSurface.mipLevels.length == 0) {
      return Failure(error("EAC R11 source texture has no mip levels."));
    }

    var order = source.format.channelOrder;
    if (order == null) {
      return Failure(error("EAC R11 source texture must expose channel ordering."));
    }

    var output = new TextureData(TextureDimension.Texture2D, source.size, PixelFormats.EAC_R11_UNORM);
    var outputSurface = output.getOrCreatePrimarySurface();
    for (mip in inputSurface.mipLevels) {
      var encoded = EacTextureBlockEncoderSupport.encodeSingleChannelMipLevel(mip, order, 0);
      outputSurface.setMipLevel(new MipLevel(mip.level, mip.size, ByteBuffer.wrap(encoded)));
    }

    return Success(new TextureBlockEncodingResult(
      TextureCompressionMethod.EacR11,
      output,
      false,
      "Encoded texture into EAC R11 blocks with the built-in baseline encoder."
    ));
  }
}
