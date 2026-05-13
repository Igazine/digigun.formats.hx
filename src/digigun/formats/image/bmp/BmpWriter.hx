package digigun.formats.image.bmp;

import digigun.formats.FormatError;
import digigun.formats.FormatErrorCode;
import digigun.formats.FormatResult;
import digigun.formats.FormatWriter;
import digigun.formats.image.ChannelOrder;
import digigun.formats.image.ChannelType;
import digigun.formats.image.TextureData;
import digigun.formats.image.TextureDimension;
import haxe.io.Bytes;

/**
 * Serializes a practical 24-bit or 32-bit uncompressed BMP file.
 */
class BmpWriter implements FormatWriter<TextureData, Bytes> {
  static inline var FILE_HEADER_SIZE = 14;
  static inline var INFO_HEADER_SIZE = 40;

  /**
   * Creates a new BMP writer.
   */
  public function new() {}

  /**
   * Writes the primary mip level of a 2D texture as a BMP image.
   */
  public function write(value:TextureData):FormatResult<Bytes> {
    if (value.dimension != TextureDimension.Texture2D) {
      return failure("BMP writing currently supports only 2D textures.");
    }

    if (value.format.isCompressed()) {
      return failure("BMP does not support compressed pixel formats.");
    }

    if (value.format.channelType != ChannelType.Unorm8) {
      return failure("BMP writing currently supports only 8-bit normalized channels.");
    }

    var channelOrder = value.format.channelOrder;
    var bytesPerPixel = switch (channelOrder) {
      case ChannelOrder.RGB, ChannelOrder.BGR:
        3;
      case ChannelOrder.RGBA, ChannelOrder.BGRA:
        4;
      default:
        return failure('BMP writing does not support channel order ${channelOrder}.');
    };

    var mip = value.getPrimaryMipLevel();
    if (mip == null) {
      return failure("BMP texture has no primary mip level.");
    }

    var width = mip.size.width;
    var height = mip.size.height;
    var rowBytes = width * bytesPerPixel;
    var paddedRowBytes = ((rowBytes + 3) >> 2) << 2;
    var pixelDataLength = paddedRowBytes * height;
    var totalLength = FILE_HEADER_SIZE + INFO_HEADER_SIZE + pixelDataLength;
    var output = Bytes.alloc(totalLength);
    var pixelOffset = FILE_HEADER_SIZE + INFO_HEADER_SIZE;

    writeUInt16LE(output, 0, "B".code | ("M".code << 8));
    writeUInt32LE(output, 2, totalLength);
    writeUInt32LE(output, 10, pixelOffset);
    writeUInt32LE(output, 14, INFO_HEADER_SIZE);
    writeUInt32LE(output, 18, width);
    writeUInt32LE(output, 22, height);
    writeUInt16LE(output, 26, 1);
    writeUInt16LE(output, 28, bytesPerPixel * 8);
    writeUInt32LE(output, 30, 0);
    writeUInt32LE(output, 34, pixelDataLength);

    for (y in 0...height) {
      var sourceRowOffset = (height - 1 - y) * rowBytes;
      var destinationRowOffset = pixelOffset + y * paddedRowBytes;
      writeRow(output, destinationRowOffset, mip.data.bytes, mip.data.offset + sourceRowOffset, width, channelOrder, bytesPerPixel);
    }

    return Success(output);
  }

  function writeRow(output:Bytes, destinationOffset:Int, source:Bytes, sourceOffset:Int, width:Int, channelOrder:ChannelOrder, bytesPerPixel:Int):Void {
    switch (channelOrder) {
      case ChannelOrder.BGR, ChannelOrder.BGRA:
        output.blit(destinationOffset, source, sourceOffset, width * bytesPerPixel);
      case ChannelOrder.RGB:
        for (pixel in 0...width) {
          var sourcePixel = sourceOffset + pixel * 3;
          var destinationPixel = destinationOffset + pixel * 3;
          output.set(destinationPixel, source.get(sourcePixel + 2));
          output.set(destinationPixel + 1, source.get(sourcePixel + 1));
          output.set(destinationPixel + 2, source.get(sourcePixel));
        }
      case ChannelOrder.RGBA:
        for (pixel in 0...width) {
          var sourcePixel = sourceOffset + pixel * 4;
          var destinationPixel = destinationOffset + pixel * 4;
          output.set(destinationPixel, source.get(sourcePixel + 2));
          output.set(destinationPixel + 1, source.get(sourcePixel + 1));
          output.set(destinationPixel + 2, source.get(sourcePixel));
          output.set(destinationPixel + 3, source.get(sourcePixel + 3));
        }
      default:
    }
  }

  function failure(message:String):FormatResult<Bytes> {
    return Failure(new FormatError(FormatErrorCode.InvalidInput, message, null, BmpFormat.id));
  }

  static function writeUInt16LE(bytes:Bytes, offset:Int, value:Int):Void {
    bytes.set(offset, value & 0xff);
    bytes.set(offset + 1, (value >> 8) & 0xff);
  }

  static function writeUInt32LE(bytes:Bytes, offset:Int, value:Int):Void {
    bytes.set(offset, value & 0xff);
    bytes.set(offset + 1, (value >> 8) & 0xff);
    bytes.set(offset + 2, (value >> 16) & 0xff);
    bytes.set(offset + 3, (value >> 24) & 0xff);
  }
}
