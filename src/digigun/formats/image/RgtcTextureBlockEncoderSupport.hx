package digigun.formats.image;

import haxe.Int64;
import haxe.io.Bytes;

/**
 * Shared helper for BC4 and BC5 style RGTC encoders.
 */
class RgtcTextureBlockEncoderSupport {
  public static function encodeSingleChannelMipLevel(mip:MipLevel, order:ChannelOrder, channelIndex:Int):Bytes {
    var blockWidth = Std.int(Math.ceil(mip.size.width / 4));
    var blockHeight = Std.int(Math.ceil(mip.size.height / 4));
    var output = Bytes.alloc(blockWidth * blockHeight * 8);
    var outputOffset = 0;

    for (blockY in 0...blockHeight) {
      for (blockX in 0...blockWidth) {
        var block = encodeSingleChannelBlock(order, mip, blockX * 4, blockY * 4, channelIndex);
        output.blit(outputOffset, block, 0, 8);
        outputOffset += 8;
      }
    }

    return output;
  }

  public static function encodeDualChannelMipLevel(mip:MipLevel, order:ChannelOrder):Bytes {
    var red = encodeSingleChannelMipLevel(mip, order, 0);
    var green = encodeSingleChannelMipLevel(mip, order, 1);
    var output = Bytes.alloc(red.length + green.length);
    output.blit(0, red, 0, red.length);
    output.blit(red.length, green, 0, green.length);
    return output;
  }

  static function encodeSingleChannelBlock(order:ChannelOrder, mip:MipLevel, originX:Int, originY:Int, channelIndex:Int):Bytes {
    var values = new Array<Int>();
    var minValue = 255;
    var maxValue = 0;

    for (localY in 0...4) {
      for (localX in 0...4) {
        var sampleX = Std.int(Math.min(mip.size.width - 1, originX + localX));
        var sampleY = Std.int(Math.min(mip.size.height - 1, originY + localY));
        var value = readChannel(order, mip, sampleX, sampleY, channelIndex);
        values.push(value);
        if (value < minValue) minValue = value;
        if (value > maxValue) maxValue = value;
      }
    }

    var endpoint0 = maxValue;
    var endpoint1 = minValue;
    if (endpoint0 <= endpoint1) {
      if (endpoint0 < 255) {
        endpoint0++;
      } else if (endpoint1 > 0) {
        endpoint1--;
      }
    }

    var palette = buildPalette(endpoint0, endpoint1);
    var indices = Int64.make(0, 0);
    for (pixelIndex in 0...values.length) {
      var bestIndex = 0;
      var bestDistance = Math.abs(values[pixelIndex] - palette[0]);
      for (paletteIndex in 1...palette.length) {
        var candidateDistance = Math.abs(values[pixelIndex] - palette[paletteIndex]);
        if (candidateDistance < bestDistance) {
          bestDistance = candidateDistance;
          bestIndex = paletteIndex;
        }
      }
      indices = Int64.or(indices, Int64.shl(Int64.ofInt(bestIndex), pixelIndex * 3));
    }

    var block = Bytes.alloc(8);
    block.set(0, endpoint0);
    block.set(1, endpoint1);
    for (byteIndex in 0...6) {
      block.set(2 + byteIndex, Int64.toInt(Int64.and(Int64.shr(indices, byteIndex * 8), Int64.ofInt(0xff))));
    }

    return block;
  }

  static function buildPalette(endpoint0:Int, endpoint1:Int):Array<Int> {
    return [
      endpoint0,
      endpoint1,
      Std.int((6 * endpoint0 + 1 * endpoint1) / 7),
      Std.int((5 * endpoint0 + 2 * endpoint1) / 7),
      Std.int((4 * endpoint0 + 3 * endpoint1) / 7),
      Std.int((3 * endpoint0 + 4 * endpoint1) / 7),
      Std.int((2 * endpoint0 + 5 * endpoint1) / 7),
      Std.int((1 * endpoint0 + 6 * endpoint1) / 7)
    ];
  }

  static function readChannel(order:ChannelOrder, mip:MipLevel, x:Int, y:Int, channelIndex:Int):Int {
    var channelCount = order.channelCount();
    var pixelOffset = mip.data.offset + (y * mip.size.width + x) * channelCount;
    var bytes = mip.data.bytes;
    return switch (order) {
      case ChannelOrder.R:
        bytes.get(pixelOffset);
      case ChannelOrder.RG:
        bytes.get(pixelOffset + channelIndex);
      case ChannelOrder.RGB:
        bytes.get(pixelOffset + channelIndex);
      case ChannelOrder.RGBA:
        bytes.get(pixelOffset + channelIndex);
      case ChannelOrder.BGR:
        bytes.get(pixelOffset + (2 - channelIndex));
      case ChannelOrder.BGRA:
        bytes.get(pixelOffset + (2 - channelIndex));
      default:
        0;
    };
  }
}
