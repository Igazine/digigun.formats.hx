package digigun.formats.image;

import haxe.Int64;
import haxe.io.Bytes;

/**
 * Shared helper for unsigned EAC block encoders.
 */
class EacTextureBlockEncoderSupport {
  static final MODIFIER_TABLES = [
    [-3, -6, -9, -15, 2, 5, 8, 14],
    [-3, -7, -10, -13, 2, 6, 9, 12],
    [-2, -5, -8, -13, 1, 4, 7, 12],
    [-2, -4, -6, -13, 1, 3, 5, 12],
    [-3, -6, -8, -12, 2, 5, 7, 11],
    [-3, -7, -9, -11, 2, 6, 8, 10],
    [-4, -7, -8, -11, 3, 6, 7, 10],
    [-3, -5, -8, -11, 2, 4, 7, 10],
    [-2, -6, -8, -10, 1, 5, 7, 9],
    [-2, -5, -8, -10, 1, 4, 7, 9],
    [-2, -4, -8, -10, 1, 3, 7, 9],
    [-2, -5, -7, -10, 1, 4, 6, 9],
    [-3, -4, -7, -10, 2, 3, 6, 9],
    [-1, -2, -3, -10, 0, 1, 2, 9],
    [-4, -6, -8, -9, 3, 5, 7, 8],
    [-3, -5, -7, -9, 2, 4, 6, 8]
  ];

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

  public static function readChannel(order:ChannelOrder, mip:MipLevel, x:Int, y:Int, channelIndex:Int):Int {
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

  static function encodeSingleChannelBlock(order:ChannelOrder, mip:MipLevel, originX:Int, originY:Int, channelIndex:Int):Bytes {
    var values = new Array<Int>();
    var minValue = 255;
    var maxValue = 0;
    var total = 0;

    for (localY in 0...4) {
      for (localX in 0...4) {
        var sampleX = Std.int(Math.min(mip.size.width - 1, originX + localX));
        var sampleY = Std.int(Math.min(mip.size.height - 1, originY + localY));
        var value = readChannel(order, mip, sampleX, sampleY, channelIndex);
        values.push(value);
        total += value;
        if (value < minValue) minValue = value;
        if (value > maxValue) maxValue = value;
      }
    }

    var baseCandidates = [
      clamp(Std.int(Math.round(total / values.length))),
      minValue,
      maxValue
    ];

    var bestBase = baseCandidates[0];
    var bestTable = 0;
    var bestMultiplier = 1;
    var bestSelectors:Array<Int> = [];
    var bestError = 1e20;

    for (candidateBase in baseCandidates) {
      for (table in 0...MODIFIER_TABLES.length) {
        for (multiplier in 0...16) {
          var effectiveMultiplier = multiplier == 0 ? 0.125 : multiplier;
          var selectors:Array<Int> = [];
          var totalError = 0.0;
          for (value in values) {
            var bestSelector = 0;
            var bestDistance = 1e20;
            for (selector in 0...8) {
              var candidate = clamp(Std.int(Math.round(candidateBase + MODIFIER_TABLES[table][selector] * effectiveMultiplier)));
              var distance = Math.abs(value - candidate);
              if (distance < bestDistance) {
                bestDistance = distance;
                bestSelector = selector;
              }
            }
            selectors.push(bestSelector);
            totalError += bestDistance;
          }

          if (totalError < bestError) {
            bestError = totalError;
            bestBase = candidateBase;
            bestTable = table;
            bestMultiplier = multiplier;
            bestSelectors = selectors;
          }
        }
      }
    }

    return packBlock(bestBase, bestMultiplier, bestTable, bestSelectors);
  }

  static function packBlock(base:Int, multiplier:Int, table:Int, selectors:Array<Int>):Bytes {
    var selectorBits = Int64.make(0, 0);
    for (pixelIndex in 0...selectors.length) {
      selectorBits = Int64.or(selectorBits, Int64.shl(Int64.ofInt(selectors[pixelIndex]), pixelIndex * 3));
    }

    var block = Bytes.alloc(8);
    block.set(7, base & 0xff);
    block.set(6, ((multiplier & 0x0f) << 4) | (table & 0x0f));
    for (byteIndex in 0...6) {
      block.set(byteIndex, Int64.toInt(Int64.and(Int64.shr(selectorBits, byteIndex * 8), Int64.ofInt(0xff))));
    }
    return block;
  }

  static function clamp(value:Int):Int {
    return value < 0 ? 0 : (value > 255 ? 255 : value);
  }
}
