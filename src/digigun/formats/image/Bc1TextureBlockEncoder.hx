package digigun.formats.image;

import digigun.formats.FormatResult;
import haxe.io.Bytes;

/**
 * Basic pure-Haxe `BC1` block encoder for RGB-style source textures.
 *
 * The current implementation prioritizes correctness and deterministic output
 * over compression quality. It is suitable as the first working encoder in the
 * GPU texture pipeline and can be refined later with better endpoint search.
 */
class Bc1TextureBlockEncoder extends AbstractTextureBlockEncoder {
  public function new() {
    super(TextureCompressionMethod.BC1, PixelFormats.BC1_RGB_UNORM);
  }

  override public function canEncode(source:TextureData, options:TextureBlockEncodingOptions):Bool {
    if (!super.canEncode(source, options)) {
      return false;
    }

    if (source.format.isCompressed()) {
      return source.format.id == PixelFormats.BC1_RGB_UNORM.id;
    }

    return source.format.id == PixelFormats.RGB8_UNORM.id
      || source.format.id == PixelFormats.BGR8_UNORM.id
      || source.format.id == PixelFormats.RGBA8_UNORM.id
      || source.format.id == PixelFormats.BGRA8_UNORM.id;
  }

  override function doEncode(source:TextureData, options:TextureBlockEncodingOptions):FormatResult<TextureBlockEncodingResult> {
    if (!canEncode(source, options)) {
      return Failure(error("BC1 encoding currently supports only RGB/BGR/RGBA/BGRA 8-bit textures."));
    }

    var inputSurface = source.getPrimarySurface();
    if (inputSurface == null || inputSurface.mipLevels.length == 0) {
      return Failure(error("BC1 source texture has no mip levels."));
    }

    var output = new TextureData(TextureDimension.Texture2D, source.size, PixelFormats.BC1_RGB_UNORM);
    var outputSurface = output.getOrCreatePrimarySurface();

    for (mip in inputSurface.mipLevels) {
      var encoded = encodeMipLevel(source.format.channelOrder, mip);
      outputSurface.setMipLevel(new MipLevel(mip.level, mip.size, ByteBuffer.wrap(encoded)));
    }

    return Success(new TextureBlockEncodingResult(
      TextureCompressionMethod.BC1,
      output,
      false,
      "Encoded texture into BC1 blocks with the built-in baseline encoder."
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
    var pixels = new Array<Bc1Rgb>();
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
        var color = readRgb(order, mip, sampleX, sampleY);
        pixels.push(color);
        if (color.r < minRed) minRed = color.r;
        if (color.g < minGreen) minGreen = color.g;
        if (color.b < minBlue) minBlue = color.b;
        if (color.r > maxRed) maxRed = color.r;
        if (color.g > maxGreen) maxGreen = color.g;
        if (color.b > maxBlue) maxBlue = color.b;
      }
    }

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
    var palette:Array<Bc1Rgb> = [
      color0,
      color1,
      interpolate(color0, color1, 2, 1),
      interpolate(color0, color1, 1, 2)
    ];

    var indices = 0;
    for (pixelIndex in 0...pixels.length) {
      var bestIndex = 0;
      var bestDistance = distanceSquared(pixels[pixelIndex], palette[0]);
      for (paletteIndex in 1...palette.length) {
        var candidateDistance = distanceSquared(pixels[pixelIndex], palette[paletteIndex]);
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

  function readRgb(order:ChannelOrder, mip:MipLevel, x:Int, y:Int):Bc1Rgb {
    var channelCount = order.channelCount();
    var pixelOffset = mip.data.offset + (y * mip.size.width + x) * channelCount;
    var bytes = mip.data.bytes;
    return switch (order) {
      case ChannelOrder.RGB:
        new Bc1Rgb(bytes.get(pixelOffset), bytes.get(pixelOffset + 1), bytes.get(pixelOffset + 2));
      case ChannelOrder.BGR:
        new Bc1Rgb(bytes.get(pixelOffset + 2), bytes.get(pixelOffset + 1), bytes.get(pixelOffset));
      case ChannelOrder.RGBA:
        new Bc1Rgb(bytes.get(pixelOffset), bytes.get(pixelOffset + 1), bytes.get(pixelOffset + 2));
      case ChannelOrder.BGRA:
        new Bc1Rgb(bytes.get(pixelOffset + 2), bytes.get(pixelOffset + 1), bytes.get(pixelOffset));
      default:
        new Bc1Rgb(0, 0, 0);
    };
  }

  function packRgb565(red:Int, green:Int, blue:Int):Int {
    var r = (red * 31 + 127) / 255;
    var g = (green * 63 + 127) / 255;
    var b = (blue * 31 + 127) / 255;
    return (Std.int(r) << 11) | (Std.int(g) << 5) | Std.int(b);
  }

  function unpackRgb565(value:Int):Bc1Rgb {
    var red = (value >> 11) & 0x1f;
    var green = (value >> 5) & 0x3f;
    var blue = value & 0x1f;
    return new Bc1Rgb(
      Std.int((red * 255 + 15) / 31),
      Std.int((green * 255 + 31) / 63),
      Std.int((blue * 255 + 15) / 31)
    );
  }

  function interpolate(a:Bc1Rgb, b:Bc1Rgb, aWeight:Int, bWeight:Int):Bc1Rgb {
    var divisor = aWeight + bWeight;
    return new Bc1Rgb(
      Std.int((a.r * aWeight + b.r * bWeight) / divisor),
      Std.int((a.g * aWeight + b.g * bWeight) / divisor),
      Std.int((a.b * aWeight + b.b * bWeight) / divisor)
    );
  }

  function distanceSquared(a:Bc1Rgb, b:Bc1Rgb):Int {
    var red = a.r - b.r;
    var green = a.g - b.g;
    var blue = a.b - b.b;
    return red * red + green * green + blue * blue;
  }
}

private class Bc1Rgb {
  public final r:Int;
  public final g:Int;
  public final b:Int;

  public function new(r:Int, g:Int, b:Int) {
    this.r = r;
    this.g = g;
    this.b = b;
  }
}
