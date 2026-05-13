package digigun.formats.image;

import digigun.formats.FormatResult;
import haxe.io.Bytes;

/**
 * Basic pure-Haxe `BC3` block encoder for RGBA-style source textures.
 */
class Bc3TextureBlockEncoder extends AbstractTextureBlockEncoder {
  public function new() {
    super(TextureCompressionMethod.BC3, PixelFormats.BC3_RGBA_UNORM);
  }

  override public function canEncode(source:TextureData, options:TextureBlockEncodingOptions):Bool {
    if (!super.canEncode(source, options)) {
      return false;
    }

    if (source.format.isCompressed()) {
      return source.format.id == PixelFormats.BC3_RGBA_UNORM.id;
    }

    return source.format.id == PixelFormats.RGB8_UNORM.id
      || source.format.id == PixelFormats.BGR8_UNORM.id
      || source.format.id == PixelFormats.RGBA8_UNORM.id
      || source.format.id == PixelFormats.BGRA8_UNORM.id;
  }

  override function doEncode(source:TextureData, options:TextureBlockEncodingOptions):FormatResult<TextureBlockEncodingResult> {
    if (!canEncode(source, options)) {
      return Failure(error("BC3 encoding currently supports only RGB/BGR/RGBA/BGRA 8-bit textures."));
    }

    var inputSurface = source.getPrimarySurface();
    if (inputSurface == null || inputSurface.mipLevels.length == 0) {
      return Failure(error("BC3 source texture has no mip levels."));
    }

    var order = source.format.channelOrder;
    if (order == null) {
      return Failure(error("BC3 source texture must expose channel ordering."));
    }

    var output = new TextureData(TextureDimension.Texture2D, source.size, PixelFormats.BC3_RGBA_UNORM);
    var outputSurface = output.getOrCreatePrimarySurface();

    for (mip in inputSurface.mipLevels) {
      var encoded = encodeMipLevel(order, mip);
      outputSurface.setMipLevel(new MipLevel(mip.level, mip.size, ByteBuffer.wrap(encoded)));
    }

    return Success(new TextureBlockEncodingResult(
      TextureCompressionMethod.BC3,
      output,
      false,
      "Encoded texture into BC3 blocks with the built-in baseline encoder."
    ));
  }

  function encodeMipLevel(order:ChannelOrder, mip:MipLevel):Bytes {
    var blockWidth = Std.int(Math.ceil(mip.size.width / 4));
    var blockHeight = Std.int(Math.ceil(mip.size.height / 4));
    var output = Bytes.alloc(blockWidth * blockHeight * 16);
    var outputOffset = 0;

    for (blockY in 0...blockHeight) {
      for (blockX in 0...blockWidth) {
        var block = encodeBlock(order, mip, blockX * 4, blockY * 4);
        output.blit(outputOffset, block, 0, 16);
        outputOffset += 16;
      }
    }

    return output;
  }

  function encodeBlock(order:ChannelOrder, mip:MipLevel, originX:Int, originY:Int):Bytes {
    var pixels:Array<Bc3Rgba> = [];
    var minAlpha = 255;
    var maxAlpha = 0;
    var minRed = 255;
    var minGreen = 255;
    var minBlue = 255;
    var maxRed = 0;
    var maxGreen = 0;
    var maxBlue = 0;

    for (localY in 0...4) {
      for (localX in 0...4) {
        var sampleX = Std.int(Math.min(mip.size.width - 1, originX + localX));
        var sampleY = Std.int(Math.min(mip.size.height - 1, originY + localY));
        var color = readRgba(order, mip, sampleX, sampleY);
        pixels.push(color);
        if (color.a < minAlpha) minAlpha = color.a;
        if (color.a > maxAlpha) maxAlpha = color.a;
        if (color.r < minRed) minRed = color.r;
        if (color.g < minGreen) minGreen = color.g;
        if (color.b < minBlue) minBlue = color.b;
        if (color.r > maxRed) maxRed = color.r;
        if (color.g > maxGreen) maxGreen = color.g;
        if (color.b > maxBlue) maxBlue = color.b;
      }
    }

    var alphaBlock = encodeAlphaBlock(pixels, minAlpha, maxAlpha);
    var colorBlock = encodeColorBlock(pixels, minRed, minGreen, minBlue, maxRed, maxGreen, maxBlue);
    var block = Bytes.alloc(16);
    block.blit(0, alphaBlock, 0, 8);
    block.blit(8, colorBlock, 0, 8);
    return block;
  }

  function encodeAlphaBlock(pixels:Array<Bc3Rgba>, minAlpha:Int, maxAlpha:Int):Bytes {
    var alpha0 = maxAlpha;
    var alpha1 = minAlpha;
    if (alpha0 <= alpha1) {
      if (alpha0 < 255) {
        alpha0++;
      } else if (alpha1 > 0) {
        alpha1--;
      }
    }

    var palette = buildAlphaPalette(alpha0, alpha1);
    var indices = haxe.Int64.make(0, 0);
    for (pixelIndex in 0...pixels.length) {
      var bestIndex = 0;
      var bestDistance = Std.int(Math.abs(pixels[pixelIndex].a - palette[0]));
      for (paletteIndex in 1...palette.length) {
        var candidateDistance = Std.int(Math.abs(pixels[pixelIndex].a - palette[paletteIndex]));
        if (candidateDistance < bestDistance) {
          bestDistance = candidateDistance;
          bestIndex = paletteIndex;
        }
      }
      indices = haxe.Int64.or(indices, haxe.Int64.shl(haxe.Int64.ofInt(bestIndex), pixelIndex * 3));
    }

    var block = Bytes.alloc(8);
    block.set(0, alpha0);
    block.set(1, alpha1);
    for (byteIndex in 0...6) {
      block.set(2 + byteIndex, haxe.Int64.toInt(haxe.Int64.and(haxe.Int64.shr(indices, byteIndex * 8), haxe.Int64.ofInt(0xff))));
    }
    return block;
  }

  function buildAlphaPalette(alpha0:Int, alpha1:Int):Array<Int> {
    return [
      alpha0,
      alpha1,
      Std.int((6 * alpha0 + 1 * alpha1) / 7),
      Std.int((5 * alpha0 + 2 * alpha1) / 7),
      Std.int((4 * alpha0 + 3 * alpha1) / 7),
      Std.int((3 * alpha0 + 4 * alpha1) / 7),
      Std.int((2 * alpha0 + 5 * alpha1) / 7),
      Std.int((1 * alpha0 + 6 * alpha1) / 7)
    ];
  }

  function encodeColorBlock(pixels:Array<Bc3Rgba>, minRed:Int, minGreen:Int, minBlue:Int, maxRed:Int, maxGreen:Int, maxBlue:Int):Bytes {
    var endpoint0 = packRgb565(maxRed, maxGreen, maxBlue);
    var endpoint1 = packRgb565(minRed, minGreen, minBlue);
    if (endpoint0 <= endpoint1) {
      if (endpoint0 < 0xffff) {
        endpoint0++;
      } else if (endpoint1 > 0) {
        endpoint1--;
      }
    }

    var color0 = unpackRgb565(endpoint0);
    var color1 = unpackRgb565(endpoint1);
    var palette:Array<Bc3Rgb> = [
      color0,
      color1,
      interpolate(color0, color1, 2, 1),
      interpolate(color0, color1, 1, 2)
    ];

    var indices = 0;
    for (pixelIndex in 0...pixels.length) {
      var rgb = new Bc3Rgb(pixels[pixelIndex].r, pixels[pixelIndex].g, pixels[pixelIndex].b);
      var bestIndex = 0;
      var bestDistance = distanceSquared(rgb, palette[0]);
      for (paletteIndex in 1...palette.length) {
        var candidateDistance = distanceSquared(rgb, palette[paletteIndex]);
        if (candidateDistance < bestDistance) {
          bestDistance = candidateDistance;
          bestIndex = paletteIndex;
        }
      }
      indices |= bestIndex << (pixelIndex * 2);
    }

    var block = Bytes.alloc(8);
    block.set(0, endpoint0 & 0xff);
    block.set(1, (endpoint0 >> 8) & 0xff);
    block.set(2, endpoint1 & 0xff);
    block.set(3, (endpoint1 >> 8) & 0xff);
    block.set(4, indices & 0xff);
    block.set(5, (indices >> 8) & 0xff);
    block.set(6, (indices >> 16) & 0xff);
    block.set(7, (indices >> 24) & 0xff);
    return block;
  }

  function readRgba(order:ChannelOrder, mip:MipLevel, x:Int, y:Int):Bc3Rgba {
    var channelCount = order.channelCount();
    var pixelOffset = mip.data.offset + (y * mip.size.width + x) * channelCount;
    var bytes = mip.data.bytes;
    return switch (order) {
      case ChannelOrder.RGB:
        new Bc3Rgba(bytes.get(pixelOffset), bytes.get(pixelOffset + 1), bytes.get(pixelOffset + 2), 255);
      case ChannelOrder.BGR:
        new Bc3Rgba(bytes.get(pixelOffset + 2), bytes.get(pixelOffset + 1), bytes.get(pixelOffset), 255);
      case ChannelOrder.RGBA:
        new Bc3Rgba(bytes.get(pixelOffset), bytes.get(pixelOffset + 1), bytes.get(pixelOffset + 2), bytes.get(pixelOffset + 3));
      case ChannelOrder.BGRA:
        new Bc3Rgba(bytes.get(pixelOffset + 2), bytes.get(pixelOffset + 1), bytes.get(pixelOffset), bytes.get(pixelOffset + 3));
      default:
        new Bc3Rgba(0, 0, 0, 255);
    };
  }

  function packRgb565(red:Int, green:Int, blue:Int):Int {
    var r = (red * 31 + 127) / 255;
    var g = (green * 63 + 127) / 255;
    var b = (blue * 31 + 127) / 255;
    return (Std.int(r) << 11) | (Std.int(g) << 5) | Std.int(b);
  }

  function unpackRgb565(value:Int):Bc3Rgb {
    var red = (value >> 11) & 0x1f;
    var green = (value >> 5) & 0x3f;
    var blue = value & 0x1f;
    return new Bc3Rgb(
      Std.int((red * 255 + 15) / 31),
      Std.int((green * 255 + 31) / 63),
      Std.int((blue * 255 + 15) / 31)
    );
  }

  function interpolate(a:Bc3Rgb, b:Bc3Rgb, aWeight:Int, bWeight:Int):Bc3Rgb {
    var divisor = aWeight + bWeight;
    return new Bc3Rgb(
      Std.int((a.r * aWeight + b.r * bWeight) / divisor),
      Std.int((a.g * aWeight + b.g * bWeight) / divisor),
      Std.int((a.b * aWeight + b.b * bWeight) / divisor)
    );
  }

  function distanceSquared(a:Bc3Rgb, b:Bc3Rgb):Int {
    var red = a.r - b.r;
    var green = a.g - b.g;
    var blue = a.b - b.b;
    return red * red + green * green + blue * blue;
  }
}

private class Bc3Rgb {
  public final r:Int;
  public final g:Int;
  public final b:Int;

  public function new(r:Int, g:Int, b:Int) {
    this.r = r;
    this.g = g;
    this.b = b;
  }
}

private class Bc3Rgba extends Bc3Rgb {
  public final a:Int;

  public function new(r:Int, g:Int, b:Int, a:Int) {
    super(r, g, b);
    this.a = a;
  }
}
