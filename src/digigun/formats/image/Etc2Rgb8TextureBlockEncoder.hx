package digigun.formats.image;

import digigun.formats.FormatResult;
import haxe.io.Bytes;

/**
 * Basic pure-Haxe `ETC2 RGB8` encoder using the ETC1-compatible individual mode.
 */
class Etc2Rgb8TextureBlockEncoder extends AbstractTextureBlockEncoder {
  static final MODIFIER_TABLES = [
    [2, 8, -2, -8],
    [5, 17, -5, -17],
    [9, 29, -9, -29],
    [13, 42, -13, -42],
    [18, 60, -18, -60],
    [24, 80, -24, -80],
    [33, 106, -33, -106],
    [47, 183, -47, -183]
  ];

  public function new() {
    super(TextureCompressionMethod.ETC2Rgb8, PixelFormats.ETC2_RGB8_UNORM);
  }

  override public function canEncode(source:TextureData, options:TextureBlockEncodingOptions):Bool {
    if (!super.canEncode(source, options)) {
      return false;
    }

    if (source.format.isCompressed()) {
      return source.format.id == PixelFormats.ETC2_RGB8_UNORM.id;
    }

    return source.format.id == PixelFormats.RGB8_UNORM.id
      || source.format.id == PixelFormats.BGR8_UNORM.id
      || source.format.id == PixelFormats.RGBA8_UNORM.id
      || source.format.id == PixelFormats.BGRA8_UNORM.id;
  }

  override function doEncode(source:TextureData, options:TextureBlockEncodingOptions):FormatResult<TextureBlockEncodingResult> {
    if (!canEncode(source, options)) {
      return Failure(error("ETC2 RGB8 encoding currently supports only RGB/BGR/RGBA/BGRA 8-bit textures."));
    }

    var inputSurface = source.getPrimarySurface();
    if (inputSurface == null || inputSurface.mipLevels.length == 0) {
      return Failure(error("ETC2 source texture has no mip levels."));
    }

    var order = source.format.channelOrder;
    if (order == null) {
      return Failure(error("ETC2 source texture must expose channel ordering."));
    }

    var output = new TextureData(TextureDimension.Texture2D, source.size, PixelFormats.ETC2_RGB8_UNORM);
    var outputSurface = output.getOrCreatePrimarySurface();

    for (mip in inputSurface.mipLevels) {
      var encoded = encodeMipLevel(order, mip);
      outputSurface.setMipLevel(new MipLevel(mip.level, mip.size, ByteBuffer.wrap(encoded)));
    }

    return Success(new TextureBlockEncodingResult(
      TextureCompressionMethod.ETC2Rgb8,
      output,
      false,
      "Encoded texture into ETC2 RGB8 blocks with the built-in baseline encoder."
    ));
  }

  function encodeMipLevel(order:ChannelOrder, mip:MipLevel):Bytes {
    var blockWidth = Std.int(Math.ceil(mip.size.width / 4));
    var blockHeight = Std.int(Math.ceil(mip.size.height / 4));
    var output = Bytes.alloc(blockWidth * blockHeight * 8);
    var outputOffset = 0;

    for (blockY in 0...blockHeight) {
      for (blockX in 0...blockWidth) {
        var block = encodeBlock(order, mip, blockX * 4, blockY * 4);
        output.blit(outputOffset, block, 0, 8);
        outputOffset += 8;
      }
    }

    return output;
  }

  function encodeBlock(order:ChannelOrder, mip:MipLevel, originX:Int, originY:Int):Bytes {
    var pixels:Array<Etc2Rgb> = [];
    for (x in 0...4) {
      for (y in 0...4) {
        var sampleX = Std.int(Math.min(mip.size.width - 1, originX + x));
        var sampleY = Std.int(Math.min(mip.size.height - 1, originY + y));
        pixels.push(readRgb(order, mip, sampleX, sampleY));
      }
    }

    var vertical = fitSplit(pixels, false);
    var horizontal = fitSplit(pixels, true);
    var best = vertical.error <= horizontal.error ? vertical : horizontal;

    var block = Bytes.alloc(8);
    block.set(0, (best.subBlock0.baseR << 4) | best.subBlock1.baseR);
    block.set(1, (best.subBlock0.baseG << 4) | best.subBlock1.baseG);
    block.set(2, (best.subBlock0.baseB << 4) | best.subBlock1.baseB);
    block.set(3, (best.subBlock0.table << 5) | (best.subBlock1.table << 2) | (best.flip ? 1 : 0));
    block.set(4, (best.msb >> 8) & 0xff);
    block.set(5, best.msb & 0xff);
    block.set(6, (best.lsb >> 8) & 0xff);
    block.set(7, best.lsb & 0xff);
    return block;
  }

  function fitSplit(pixels:Array<Etc2Rgb>, flip:Bool):Etc2BlockFit {
    var first:Array<Etc2Rgb> = [];
    var second:Array<Etc2Rgb> = [];
    var pixelToSubBlock:Array<Int> = [];

    for (x in 0...4) {
      for (y in 0...4) {
        var index = x * 4 + y;
        var subBlock = flip ? (y < 2 ? 0 : 1) : (x < 2 ? 0 : 1);
        pixelToSubBlock[index] = subBlock;
        if (subBlock == 0) {
          first.push(pixels[index]);
        } else {
          second.push(pixels[index]);
        }
      }
    }

    var firstFit = fitSubBlock(first);
    var secondFit = fitSubBlock(second);
    var msb = 0;
    var lsb = 0;
    var firstIndex = 0;
    var secondIndex = 0;

    for (index in 0...pixels.length) {
      var selector = if (pixelToSubBlock[index] == 0) {
        firstFit.selectors[firstIndex++];
      } else {
        secondFit.selectors[secondIndex++];
      };
      lsb |= (selector & 1) << index;
      msb |= ((selector >> 1) & 1) << index;
    }

    return new Etc2BlockFit(firstFit.tableFit, secondFit.tableFit, flip, msb, lsb, firstFit.error + secondFit.error);
  }

  function fitSubBlock(pixels:Array<Etc2Rgb>):Etc2SubBlockFitResult {
    var sumR = 0;
    var sumG = 0;
    var sumB = 0;
    for (pixel in pixels) {
      sumR += pixel.r;
      sumG += pixel.g;
      sumB += pixel.b;
    }

    var average = new Etc2Rgb(
      Std.int(sumR / pixels.length),
      Std.int(sumG / pixels.length),
      Std.int(sumB / pixels.length)
    );
    var baseR = quantize4(average.r);
    var baseG = quantize4(average.g);
    var baseB = quantize4(average.b);
    var expandedBase = expand4(baseR, baseG, baseB);

    var bestTable = 0;
    var bestSelectors:Array<Int> = [];
    var bestError = 0x7fffffff;

    for (table in 0...MODIFIER_TABLES.length) {
      var selectors:Array<Int> = [];
      var totalError = 0;
      for (pixel in pixels) {
        var bestSelector = 0;
        var bestDistance = 0x7fffffff;
        for (selector in 0...4) {
          var modifier = MODIFIER_TABLES[table][selector];
          var candidate = new Etc2Rgb(
            clamp(expandedBase.r + modifier),
            clamp(expandedBase.g + modifier),
            clamp(expandedBase.b + modifier)
          );
          var distance = distanceSquared(pixel, candidate);
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
        bestTable = table;
        bestSelectors = selectors;
      }
    }

    return new Etc2SubBlockFitResult(
      new Etc2SubBlockFit(baseR, baseG, baseB, bestTable),
      bestSelectors,
      bestError
    );
  }

  function readRgb(order:ChannelOrder, mip:MipLevel, x:Int, y:Int):Etc2Rgb {
    var channelCount = order.channelCount();
    var pixelOffset = mip.data.offset + (y * mip.size.width + x) * channelCount;
    var bytes = mip.data.bytes;
    return switch (order) {
      case ChannelOrder.RGB:
        new Etc2Rgb(bytes.get(pixelOffset), bytes.get(pixelOffset + 1), bytes.get(pixelOffset + 2));
      case ChannelOrder.BGR:
        new Etc2Rgb(bytes.get(pixelOffset + 2), bytes.get(pixelOffset + 1), bytes.get(pixelOffset));
      case ChannelOrder.RGBA:
        new Etc2Rgb(bytes.get(pixelOffset), bytes.get(pixelOffset + 1), bytes.get(pixelOffset + 2));
      case ChannelOrder.BGRA:
        new Etc2Rgb(bytes.get(pixelOffset + 2), bytes.get(pixelOffset + 1), bytes.get(pixelOffset));
      default:
        new Etc2Rgb(0, 0, 0);
    };
  }

  function quantize4(value:Int):Int {
    return Std.int((value * 15 + 127) / 255);
  }

  function expand4(red:Int, green:Int, blue:Int):Etc2Rgb {
    return new Etc2Rgb(red * 17, green * 17, blue * 17);
  }

  function clamp(value:Int):Int {
    return value < 0 ? 0 : (value > 255 ? 255 : value);
  }

  function distanceSquared(a:Etc2Rgb, b:Etc2Rgb):Int {
    var red = a.r - b.r;
    var green = a.g - b.g;
    var blue = a.b - b.b;
    return red * red + green * green + blue * blue;
  }
}

private class Etc2Rgb {
  public final r:Int;
  public final g:Int;
  public final b:Int;

  public function new(r:Int, g:Int, b:Int) {
    this.r = r;
    this.g = g;
    this.b = b;
  }
}

private class Etc2SubBlockFit {
  public final baseR:Int;
  public final baseG:Int;
  public final baseB:Int;
  public final table:Int;

  public function new(baseR:Int, baseG:Int, baseB:Int, table:Int) {
    this.baseR = baseR;
    this.baseG = baseG;
    this.baseB = baseB;
    this.table = table;
  }
}

private class Etc2SubBlockFitResult {
  public final tableFit:Etc2SubBlockFit;
  public final selectors:Array<Int>;
  public final error:Int;

  public function new(tableFit:Etc2SubBlockFit, selectors:Array<Int>, error:Int) {
    this.tableFit = tableFit;
    this.selectors = selectors;
    this.error = error;
  }
}

private class Etc2BlockFit {
  public final subBlock0:Etc2SubBlockFit;
  public final subBlock1:Etc2SubBlockFit;
  public final flip:Bool;
  public final msb:Int;
  public final lsb:Int;
  public final error:Int;

  public function new(subBlock0:Etc2SubBlockFit, subBlock1:Etc2SubBlockFit, flip:Bool, msb:Int, lsb:Int, error:Int) {
    this.subBlock0 = subBlock0;
    this.subBlock1 = subBlock1;
    this.flip = flip;
    this.msb = msb;
    this.lsb = lsb;
    this.error = error;
  }
}
