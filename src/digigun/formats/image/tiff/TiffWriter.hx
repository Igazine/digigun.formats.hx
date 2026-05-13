package digigun.formats.image.tiff;

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
 * Serializes a practical little-endian baseline TIFF subset.
 */
class TiffWriter implements FormatWriter<TextureData, Bytes> {
  static inline var TYPE_SHORT = 3;
  static inline var TYPE_LONG = 4;

  static inline var TAG_IMAGE_WIDTH = 256;
  static inline var TAG_IMAGE_LENGTH = 257;
  static inline var TAG_BITS_PER_SAMPLE = 258;
  static inline var TAG_COMPRESSION = 259;
  static inline var TAG_PHOTOMETRIC = 262;
  static inline var TAG_STRIP_OFFSETS = 273;
  static inline var TAG_SAMPLES_PER_PIXEL = 277;
  static inline var TAG_ROWS_PER_STRIP = 278;
  static inline var TAG_STRIP_BYTE_COUNTS = 279;
  static inline var TAG_PLANAR_CONFIGURATION = 284;

  /**
   * Creates a new TIFF writer.
   */
  public function new() {}

  /**
   * Writes the primary mip level of a 2D texture as a little-endian TIFF file.
   */
  public function write(value:TextureData):FormatResult<Bytes> {
    if (value.dimension != TextureDimension.Texture2D) {
      return failure("TIFF writing currently supports only 2D textures.");
    }

    if (value.format.isCompressed()) {
      return failure("TIFF writing does not support compressed pixel formats.");
    }

    if (value.format.channelType != ChannelType.Unorm8) {
      return failure("TIFF writing currently supports only 8-bit normalized channels.");
    }

    var channelOrder = value.format.channelOrder;
    var samplesPerPixel = switch (channelOrder) {
      case ChannelOrder.R:
        1;
      case ChannelOrder.RGB, ChannelOrder.BGR:
        3;
      case ChannelOrder.RGBA, ChannelOrder.BGRA:
        4;
      default:
        return failure('TIFF writing does not support channel order ${channelOrder}.');
    };

    var photometric = samplesPerPixel == 1 ? 1 : 2;
    var mip = value.getPrimaryMipLevel();
    if (mip == null) {
      return failure("TIFF texture has no primary mip level.");
    }

    var width = mip.size.width;
    var height = mip.size.height;
    var pixelDataLength = width * height * samplesPerPixel;
    if (mip.data.length != pixelDataLength) {
      return failure("TIFF primary mip byte length does not match the expected image size.");
    }

    var entryCount = samplesPerPixel == 1 ? 9 : 10;
    var ifdOffset = 8;
    var ifdLength = 2 + entryCount * 12 + 4;
    var bitsOffset = samplesPerPixel == 1 ? 0 : ifdOffset + ifdLength;
    var bitsLength = samplesPerPixel == 1 ? 0 : samplesPerPixel * 2;
    var pixelOffset = ifdOffset + ifdLength + bitsLength;
    var output = Bytes.alloc(pixelOffset + pixelDataLength);

    output.blit(pixelOffset, encodePixels(mip.data.bytes, mip.data.offset, width * height, channelOrder), 0, pixelDataLength);

    output.set(0, "I".code);
    output.set(1, "I".code);
    writeUInt16LE(output, 2, 42);
    writeUInt32LE(output, 4, ifdOffset);

    var offset = ifdOffset;
    writeUInt16LE(output, offset, entryCount);
    offset += 2;

    offset = writeEntry(output, offset, TAG_IMAGE_WIDTH, TYPE_LONG, 1, width);
    offset = writeEntry(output, offset, TAG_IMAGE_LENGTH, TYPE_LONG, 1, height);
    if (samplesPerPixel == 1) {
      offset = writeEntry(output, offset, TAG_BITS_PER_SAMPLE, TYPE_SHORT, 1, 8);
    } else {
      offset = writeEntry(output, offset, TAG_BITS_PER_SAMPLE, TYPE_SHORT, samplesPerPixel, bitsOffset);
    }
    offset = writeEntry(output, offset, TAG_COMPRESSION, TYPE_SHORT, 1, 1);
    offset = writeEntry(output, offset, TAG_PHOTOMETRIC, TYPE_SHORT, 1, photometric);
    offset = writeEntry(output, offset, TAG_STRIP_OFFSETS, TYPE_LONG, 1, pixelOffset);
    offset = writeEntry(output, offset, TAG_SAMPLES_PER_PIXEL, TYPE_SHORT, 1, samplesPerPixel);
    offset = writeEntry(output, offset, TAG_ROWS_PER_STRIP, TYPE_LONG, 1, height);
    offset = writeEntry(output, offset, TAG_STRIP_BYTE_COUNTS, TYPE_LONG, 1, pixelDataLength);
    if (samplesPerPixel > 1) {
      offset = writeEntry(output, offset, TAG_PLANAR_CONFIGURATION, TYPE_SHORT, 1, 1);
    }
    writeUInt32LE(output, offset, 0);

    if (samplesPerPixel > 1) {
      for (index in 0...samplesPerPixel) {
        writeUInt16LE(output, bitsOffset + index * 2, 8);
      }
    }

    return Success(output);
  }

  function encodePixels(source:Bytes, sourceOffset:Int, pixelCount:Int, channelOrder:ChannelOrder):Bytes {
    var output = Bytes.alloc(pixelCount * channelOrder.channelCount());
    switch (channelOrder) {
      case ChannelOrder.R, ChannelOrder.RGB, ChannelOrder.RGBA:
        output.blit(0, source, sourceOffset, output.length);
      case ChannelOrder.BGR:
        for (pixel in 0...pixelCount) {
          var sourcePixel = sourceOffset + pixel * 3;
          var destinationPixel = pixel * 3;
          output.set(destinationPixel, source.get(sourcePixel + 2));
          output.set(destinationPixel + 1, source.get(sourcePixel + 1));
          output.set(destinationPixel + 2, source.get(sourcePixel));
        }
      case ChannelOrder.BGRA:
        for (pixel in 0...pixelCount) {
          var sourcePixel = sourceOffset + pixel * 4;
          var destinationPixel = pixel * 4;
          output.set(destinationPixel, source.get(sourcePixel + 2));
          output.set(destinationPixel + 1, source.get(sourcePixel + 1));
          output.set(destinationPixel + 2, source.get(sourcePixel));
          output.set(destinationPixel + 3, source.get(sourcePixel + 3));
        }
      default:
    }
    return output;
  }

  function writeEntry(bytes:Bytes, offset:Int, tag:Int, fieldType:Int, count:Int, value:Int):Int {
    writeUInt16LE(bytes, offset, tag);
    writeUInt16LE(bytes, offset + 2, fieldType);
    writeUInt32LE(bytes, offset + 4, count);
    switch (fieldType) {
      case TYPE_SHORT if (count == 1):
        writeUInt16LE(bytes, offset + 8, value);
        writeUInt16LE(bytes, offset + 10, 0);
      case TYPE_LONG if (count == 1):
        writeUInt32LE(bytes, offset + 8, value);
      default:
        writeUInt32LE(bytes, offset + 8, value);
    }
    return offset + 12;
  }

  function failure(message:String):FormatResult<Bytes> {
    return Failure(new FormatError(FormatErrorCode.InvalidInput, message, null, TiffFormat.id));
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
