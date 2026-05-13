package digigun.formats.image;

import digigun.formats.FormatResult;
import haxe.io.Bytes;

/**
 * Basic pure-Haxe `ETC2 RGBA8` encoder using ETC2 RGB plus unsigned EAC alpha.
 */
class Etc2Rgba8TextureBlockEncoder extends AbstractTextureBlockEncoder {
  final rgbEncoder:Etc2Rgb8TextureBlockEncoder;

  public function new() {
    super(TextureCompressionMethod.ETC2Rgba8, PixelFormats.ETC2_RGBA8_UNORM);
    rgbEncoder = new Etc2Rgb8TextureBlockEncoder();
  }

  override public function canEncode(source:TextureData, options:TextureBlockEncodingOptions):Bool {
    if (!super.canEncode(source, options)) {
      return false;
    }

    if (source.format.isCompressed()) {
      return source.format.id == PixelFormats.ETC2_RGBA8_UNORM.id;
    }

    return source.format.id == PixelFormats.RGB8_UNORM.id
      || source.format.id == PixelFormats.BGR8_UNORM.id
      || source.format.id == PixelFormats.RGBA8_UNORM.id
      || source.format.id == PixelFormats.BGRA8_UNORM.id;
  }

  override function doEncode(source:TextureData, options:TextureBlockEncodingOptions):FormatResult<TextureBlockEncodingResult> {
    if (!canEncode(source, options)) {
      return Failure(error("ETC2 RGBA8 encoding currently supports only RGB/BGR/RGBA/BGRA 8-bit textures."));
    }

    var inputSurface = source.getPrimarySurface();
    if (inputSurface == null || inputSurface.mipLevels.length == 0) {
      return Failure(error("ETC2 RGBA8 source texture has no mip levels."));
    }

    var order = source.format.channelOrder;
    if (order == null) {
      return Failure(error("ETC2 RGBA8 source texture must expose channel ordering."));
    }

    var output = new TextureData(TextureDimension.Texture2D, source.size, PixelFormats.ETC2_RGBA8_UNORM);
    var outputSurface = output.getOrCreatePrimarySurface();

    for (mip in inputSurface.mipLevels) {
      var rgbTexture = TextureData.fromBuffer2D(mip.size, PixelFormats.RGB8_UNORM, ByteBuffer.wrap(extractRgbMip(order, mip)));
      var alphaTexture = TextureData.fromBuffer2D(mip.size, PixelFormats.R8_UNORM, ByteBuffer.wrap(extractAlphaMip(order, mip)));

      var rgbBytes = encodeRgb(rgbTexture);
      var alphaBytes = encodeAlpha(alphaTexture);
      var encoded = Bytes.alloc(alphaBytes.length + rgbBytes.length);
      encoded.blit(0, alphaBytes, 0, alphaBytes.length);
      encoded.blit(alphaBytes.length, rgbBytes, 0, rgbBytes.length);
      outputSurface.setMipLevel(new MipLevel(mip.level, mip.size, ByteBuffer.wrap(encoded)));
    }

    return Success(new TextureBlockEncodingResult(
      TextureCompressionMethod.ETC2Rgba8,
      output,
      false,
      "Encoded texture into ETC2 RGBA8 blocks with the built-in baseline encoder."
    ));
  }

  function encodeRgb(texture:TextureData):Bytes {
    switch (rgbEncoder.encode(texture, new TextureBlockEncodingOptions())) {
      case Success(result):
        return result.texture.getPrimaryMipLevel().data.toBytes();
      case Failure(error):
        throw error;
    }
  }

  function encodeAlpha(texture:TextureData):Bytes {
    var encoder = new EacR11TextureBlockEncoder();
    switch (encoder.encode(texture, new TextureBlockEncodingOptions())) {
      case Success(result):
        return result.texture.getPrimaryMipLevel().data.toBytes();
      case Failure(error):
        throw error;
    }
  }

  function extractRgbMip(order:ChannelOrder, mip:MipLevel):Bytes {
    var channelCount = order.channelCount();
    var output = Bytes.alloc(mip.size.width * mip.size.height * 3);
    for (pixel in 0...mip.size.width * mip.size.height) {
      var sourceOffset = mip.data.offset + pixel * channelCount;
      var destinationOffset = pixel * 3;
      switch (order) {
        case ChannelOrder.RGB:
          output.set(destinationOffset, mip.data.bytes.get(sourceOffset));
          output.set(destinationOffset + 1, mip.data.bytes.get(sourceOffset + 1));
          output.set(destinationOffset + 2, mip.data.bytes.get(sourceOffset + 2));
        case ChannelOrder.BGR:
          output.set(destinationOffset, mip.data.bytes.get(sourceOffset + 2));
          output.set(destinationOffset + 1, mip.data.bytes.get(sourceOffset + 1));
          output.set(destinationOffset + 2, mip.data.bytes.get(sourceOffset));
        case ChannelOrder.RGBA:
          output.set(destinationOffset, mip.data.bytes.get(sourceOffset));
          output.set(destinationOffset + 1, mip.data.bytes.get(sourceOffset + 1));
          output.set(destinationOffset + 2, mip.data.bytes.get(sourceOffset + 2));
        case ChannelOrder.BGRA:
          output.set(destinationOffset, mip.data.bytes.get(sourceOffset + 2));
          output.set(destinationOffset + 1, mip.data.bytes.get(sourceOffset + 1));
          output.set(destinationOffset + 2, mip.data.bytes.get(sourceOffset));
        default:
          output.set(destinationOffset, 0);
          output.set(destinationOffset + 1, 0);
          output.set(destinationOffset + 2, 0);
      }
    }
    return output;
  }

  function extractAlphaMip(order:ChannelOrder, mip:MipLevel):Bytes {
    var channelCount = order.channelCount();
    var output = Bytes.alloc(mip.size.width * mip.size.height);
    for (pixel in 0...mip.size.width * mip.size.height) {
      var sourceOffset = mip.data.offset + pixel * channelCount;
      var alpha = switch (order) {
        case ChannelOrder.RGBA:
          mip.data.bytes.get(sourceOffset + 3);
        case ChannelOrder.BGRA:
          mip.data.bytes.get(sourceOffset + 3);
        default:
          255;
      };
      output.set(pixel, alpha);
    }
    return output;
  }
}
