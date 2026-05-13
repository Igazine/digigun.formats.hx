package digigun.formats.image.ppm;

import digigun.formats.FormatError;
import digigun.formats.FormatErrorCode;
import digigun.formats.FormatResult;
import digigun.formats.FormatWriter;
import digigun.formats.image.ChannelOrder;
import digigun.formats.image.ChannelType;
import digigun.formats.image.TextureData;
import digigun.formats.image.TextureDimension;
import haxe.io.Bytes;

class PpmWriter implements FormatWriter<TextureData, Bytes> {
  public function new() {}

  public function write(value:TextureData):FormatResult<Bytes> {
    if (value.dimension != TextureDimension.Texture2D) {
      return failure("PPM/PGM writing currently supports only 2D textures.");
    }

    if (value.format.isCompressed() || value.format.channelType != ChannelType.Unorm8) {
      return failure("PPM/PGM writing currently supports only uncompressed 8-bit normalized formats.");
    }

    var mip = value.getPrimaryMipLevel();
    if (mip == null) {
      return failure("PPM/PGM texture has no primary mip level.");
    }

    var order = value.format.channelOrder;
    var signature = switch (order) {
      case ChannelOrder.R:
        "P5";
      case ChannelOrder.RGB, ChannelOrder.BGR:
        "P6";
      default:
        return failure('PPM/PGM writing does not support channel order ${order}.');
    };

    var header = Bytes.ofString('${signature}\n${mip.size.width} ${mip.size.height}\n255\n');
    var payload = encodePixels(mip.data.toBytes(), order);
    var output = Bytes.alloc(header.length + payload.length);
    output.blit(0, header, 0, header.length);
    output.blit(header.length, payload, 0, payload.length);
    return Success(output);
  }

  function encodePixels(source:Bytes, order:ChannelOrder):Bytes {
    return switch (order) {
      case ChannelOrder.R, ChannelOrder.RGB:
        source;
      case ChannelOrder.BGR:
        var output = Bytes.alloc(source.length);
        for (pixel in 0...Std.int(source.length / 3)) {
          var sourceOffset = pixel * 3;
          output.set(sourceOffset, source.get(sourceOffset + 2));
          output.set(sourceOffset + 1, source.get(sourceOffset + 1));
          output.set(sourceOffset + 2, source.get(sourceOffset));
        }
        output;
      default:
        Bytes.alloc(0);
    };
  }

  function failure(message:String):FormatResult<Bytes> {
    return Failure(new FormatError(FormatErrorCode.InvalidInput, message, null, PpmFormat.id));
  }
}
