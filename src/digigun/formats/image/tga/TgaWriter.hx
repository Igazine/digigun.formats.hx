package digigun.formats.image.tga;

import digigun.formats.FormatError;
import digigun.formats.FormatErrorCode;
import digigun.formats.FormatResult;
import digigun.formats.FormatWriter;
import digigun.formats.image.ChannelOrder;
import digigun.formats.image.ChannelType;
import digigun.formats.image.TextureData;
import digigun.formats.image.TextureDimension;
import haxe.io.BytesBuffer;
import haxe.io.Bytes;

class TgaWriter implements FormatWriter<TextureData, Bytes> {
  public function new() {}

  public function write(value:TextureData):FormatResult<Bytes> {
    if (value.dimension != TextureDimension.Texture2D) {
      return failure("TGA writing currently supports only 2D textures.");
    }

    if (value.format.isCompressed() || value.format.channelType != ChannelType.Unorm8) {
      return failure("TGA writing currently supports only uncompressed 8-bit normalized formats.");
    }

    var mip = value.getPrimaryMipLevel();
    if (mip == null) {
      return failure("TGA texture has no primary mip level.");
    }

    var order = value.format.channelOrder;
    var bytesPerPixel = switch (order) {
      case ChannelOrder.R:
        1;
      case ChannelOrder.RGB, ChannelOrder.BGR:
        3;
      case ChannelOrder.RGBA, ChannelOrder.BGRA:
        4;
      default:
        return failure('Unsupported TGA channel order: ${order}');
    };

    var pixelBytes = encodePixels(mip.data.toBytes(), order);
    var rleBytes = encodeRlePixels(pixelBytes, bytesPerPixel);
    var useRle = rleBytes != null && rleBytes.length <= pixelBytes.length;
    var data = useRle ? rleBytes : pixelBytes;
    var output = Bytes.alloc(18 + data.length);
    output.set(2, bytesPerPixel == 1 ? (useRle ? 11 : 3) : (useRle ? 10 : 2));
    output.set(12, mip.size.width & 0xff);
    output.set(13, (mip.size.width >> 8) & 0xff);
    output.set(14, mip.size.height & 0xff);
    output.set(15, (mip.size.height >> 8) & 0xff);
    output.set(16, bytesPerPixel * 8);
    output.set(17, 0x20 | (bytesPerPixel == 4 ? 8 : 0));
    output.blit(18, data, 0, data.length);
    return Success(output);
  }

  function encodeRlePixels(source:Bytes, bytesPerPixel:Int):Bytes {
    var pixelCount = Std.int(source.length / bytesPerPixel);
    if (pixelCount <= 0) {
      return Bytes.alloc(0);
    }

    var buffer = new BytesBuffer();
    var pixel = 0;
    while (pixel < pixelCount) {
      var runLength = 1;
      while (pixel + runLength < pixelCount && runLength < 128 && pixelsEqual(source, pixel * bytesPerPixel, (pixel + runLength) * bytesPerPixel, bytesPerPixel)) {
        runLength++;
      }

      if (runLength >= 2) {
        buffer.addByte(0x80 | (runLength - 1));
        addPixel(buffer, source, pixel * bytesPerPixel, bytesPerPixel);
        pixel += runLength;
        continue;
      }

      var rawStart = pixel;
      var rawLength = 1;
      while (rawStart + rawLength < pixelCount && rawLength < 128) {
        var nextRun = 1;
        while (
          rawStart + rawLength + nextRun < pixelCount &&
          nextRun < 128 &&
          pixelsEqual(source, (rawStart + rawLength + nextRun - 1) * bytesPerPixel, (rawStart + rawLength + nextRun) * bytesPerPixel, bytesPerPixel)
        ) {
          nextRun++;
        }

        if (nextRun >= 2) {
          break;
        }

        rawLength++;
      }

      buffer.addByte(rawLength - 1);
      for (index in 0...rawLength) {
        addPixel(buffer, source, (rawStart + index) * bytesPerPixel, bytesPerPixel);
      }
      pixel += rawLength;
    }

    return buffer.getBytes();
  }

  function addPixel(buffer:BytesBuffer, source:Bytes, offset:Int, bytesPerPixel:Int):Void {
    for (index in 0...bytesPerPixel) {
      buffer.addByte(source.get(offset + index));
    }
  }

  function pixelsEqual(source:Bytes, leftOffset:Int, rightOffset:Int, bytesPerPixel:Int):Bool {
    for (index in 0...bytesPerPixel) {
      if (source.get(leftOffset + index) != source.get(rightOffset + index)) {
        return false;
      }
    }
    return true;
  }

  function encodePixels(source:Bytes, order:ChannelOrder):Bytes {
    return switch (order) {
      case ChannelOrder.R, ChannelOrder.BGR, ChannelOrder.BGRA:
        source;
      case ChannelOrder.RGB:
        var output = Bytes.alloc(source.length);
        for (pixel in 0...Std.int(source.length / 3)) {
          var sourceOffset = pixel * 3;
          output.set(sourceOffset, source.get(sourceOffset + 2));
          output.set(sourceOffset + 1, source.get(sourceOffset + 1));
          output.set(sourceOffset + 2, source.get(sourceOffset));
        }
        output;
      case ChannelOrder.RGBA:
        var output = Bytes.alloc(source.length);
        for (pixel in 0...Std.int(source.length / 4)) {
          var sourceOffset = pixel * 4;
          output.set(sourceOffset, source.get(sourceOffset + 2));
          output.set(sourceOffset + 1, source.get(sourceOffset + 1));
          output.set(sourceOffset + 2, source.get(sourceOffset));
          output.set(sourceOffset + 3, source.get(sourceOffset + 3));
        }
        output;
      default:
        Bytes.alloc(0);
    };
  }

  function failure(message:String):FormatResult<Bytes> {
    return Failure(new FormatError(FormatErrorCode.InvalidInput, message, null, TgaFormat.id));
  }
}
