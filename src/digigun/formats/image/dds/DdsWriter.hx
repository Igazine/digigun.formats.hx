package digigun.formats.image.dds;

import digigun.formats.FormatError;
import digigun.formats.FormatErrorCode;
import digigun.formats.FormatResult;
import digigun.formats.FormatWriter;
import digigun.formats.image.ChannelOrder;
import digigun.formats.image.ChannelType;
import digigun.formats.image.MipLevel;
import digigun.formats.image.PixelFormat;
import digigun.formats.image.PixelFormats;
import digigun.formats.image.TextureData;
import digigun.formats.image.TextureDimension;
import digigun.formats.image.internal.BinaryTools;
import haxe.io.Bytes;

/**
 * Writes a practical DDS subset with one 2D texture and optional mipmaps.
 */
class DdsWriter implements FormatWriter<TextureData, Bytes> {
  static inline var DDS_MAGIC = 0x20534444;
  static inline var DDSD_CAPS = 0x1;
  static inline var DDSD_HEIGHT = 0x2;
  static inline var DDSD_WIDTH = 0x4;
  static inline var DDSD_PITCH = 0x8;
  static inline var DDSD_PIXELFORMAT = 0x1000;
  static inline var DDSD_MIPMAPCOUNT = 0x20000;
  static inline var DDSD_LINEARSIZE = 0x80000;
  static inline var DDSCAPS_TEXTURE = 0x1000;
  static inline var DDSCAPS_COMPLEX = 0x8;
  static inline var DDSCAPS_MIPMAP = 0x400000;
  static inline var DDPF_ALPHA = 0x1;
  static inline var DDPF_FOURCC = 0x4;
  static inline var DDPF_RGB = 0x40;

  public function new() {}

  public function write(value:TextureData):FormatResult<Bytes> {
    if (value.dimension != TextureDimension.Texture2D) {
      return failure("DDS writing currently supports only 2D textures.");
    }

    var surface = value.getPrimarySurface();
    if (surface == null || surface.mipLevels.length == 0) {
      return failure("DDS texture has no mip levels.");
    }

    var formatInfo = resolveFormat(value.format);
    if (formatInfo == null) {
      return failure('Unsupported DDS write format: ${value.format.id}');
    }

    if (!formatInfo.compressed && value.format.channelType != ChannelType.Unorm8) {
      return failure("DDS writing currently supports only 8-bit normalized uncompressed channels.");
    }

    var totalDataBytes = 0;
    for (mip in surface.mipLevels) {
      totalDataBytes += mip.data.length;
    }

    var output = Bytes.alloc(128 + totalDataBytes);
    BinaryTools.writeUInt32LE(output, 0, DDS_MAGIC);
    BinaryTools.writeUInt32LE(output, 4, 124);

    var flags = DDSD_CAPS | DDSD_HEIGHT | DDSD_WIDTH | DDSD_PIXELFORMAT | (formatInfo.compressed ? DDSD_LINEARSIZE : DDSD_PITCH);
    if (surface.mipLevels.length > 1) {
      flags |= DDSD_MIPMAPCOUNT;
    }
    BinaryTools.writeUInt32LE(output, 8, flags);
    BinaryTools.writeUInt32LE(output, 12, value.size.height);
    BinaryTools.writeUInt32LE(output, 16, value.size.width);
    BinaryTools.writeUInt32LE(output, 20, formatInfo.compressed ? surface.mipLevels[0].data.length : value.size.width * formatInfo.bytesPerPixel);
    BinaryTools.writeUInt32LE(output, 28, surface.mipLevels.length);

    BinaryTools.writeUInt32LE(output, 76, 32);
    BinaryTools.writeUInt32LE(output, 80, formatInfo.pixelFlags);
    BinaryTools.writeUInt32LE(output, 84, formatInfo.fourCC);
    BinaryTools.writeUInt32LE(output, 88, formatInfo.bitCount);
    BinaryTools.writeUInt32LE(output, 92, formatInfo.rMask);
    BinaryTools.writeUInt32LE(output, 96, formatInfo.gMask);
    BinaryTools.writeUInt32LE(output, 100, formatInfo.bMask);
    BinaryTools.writeUInt32LE(output, 104, formatInfo.aMask);

    var caps = DDSCAPS_TEXTURE;
    if (surface.mipLevels.length > 1) {
      caps |= DDSCAPS_COMPLEX | DDSCAPS_MIPMAP;
    }
    BinaryTools.writeUInt32LE(output, 108, caps);

    var dataOffset = 128;
    for (mip in surface.mipLevels) {
      var encoded = formatInfo.compressed ? mip.data.toBytes() : encodeUncompressed(mip, value.format.channelOrder);
      output.blit(dataOffset, encoded, 0, encoded.length);
      dataOffset += encoded.length;
    }

    return Success(output);
  }

  function encodeUncompressed(mip:MipLevel, order:ChannelOrder):Bytes {
    var pixelCount = mip.size.width * mip.size.height * mip.size.depth;
    return switch (order) {
      case ChannelOrder.BGR, ChannelOrder.BGRA:
        mip.data.toBytes();
      case ChannelOrder.RGB:
        var output = Bytes.alloc(pixelCount * 3);
        for (pixel in 0...pixelCount) {
          var source = mip.data.offset + pixel * 3;
          var destination = pixel * 3;
          output.set(destination, mip.data.bytes.get(source + 2));
          output.set(destination + 1, mip.data.bytes.get(source + 1));
          output.set(destination + 2, mip.data.bytes.get(source));
        }
        output;
      case ChannelOrder.RGBA:
        var output = Bytes.alloc(pixelCount * 4);
        for (pixel in 0...pixelCount) {
          var source = mip.data.offset + pixel * 4;
          var destination = pixel * 4;
          output.set(destination, mip.data.bytes.get(source + 2));
          output.set(destination + 1, mip.data.bytes.get(source + 1));
          output.set(destination + 2, mip.data.bytes.get(source));
          output.set(destination + 3, mip.data.bytes.get(source + 3));
        }
        output;
      default:
        Bytes.alloc(0);
    };
  }

  function resolveFormat(format:PixelFormat):Null<DdsWriteFormatInfo> {
    return switch (format.id) {
      case "bc1-rgb-unorm":
        new DdsWriteFormatInfo(true, DDPF_FOURCC, BinaryTools.fourCC("DXT1"), 0, 0, 0, 0, 0, 0);
      case "bc3-rgba-unorm":
        new DdsWriteFormatInfo(true, DDPF_FOURCC, BinaryTools.fourCC("DXT5"), 0, 0, 0, 0, 0, 0);
      case "bc4-r-unorm":
        new DdsWriteFormatInfo(true, DDPF_FOURCC, BinaryTools.fourCC("ATI1"), 0, 0, 0, 0, 0, 0);
      case "bc5-rg-unorm":
        new DdsWriteFormatInfo(true, DDPF_FOURCC, BinaryTools.fourCC("ATI2"), 0, 0, 0, 0, 0, 0);
      case "bgr8-unorm", "rgb8-unorm":
        new DdsWriteFormatInfo(false, DDPF_RGB, 0, 24, 0x00ff0000, 0x0000ff00, 0x000000ff, 0, 3);
      case "bgra8-unorm", "rgba8-unorm":
        new DdsWriteFormatInfo(false, DDPF_RGB | DDPF_ALPHA, 0, 32, 0x00ff0000, 0x0000ff00, 0x000000ff, 0xff000000, 4);
      default:
        null;
    };
  }

  function failure(message:String):FormatResult<Bytes> {
    return Failure(new FormatError(FormatErrorCode.InvalidInput, message, null, DdsFormat.id));
  }
}

private class DdsWriteFormatInfo {
  public final compressed:Bool;
  public final pixelFlags:Int;
  public final fourCC:Int;
  public final bitCount:Int;
  public final rMask:Int;
  public final gMask:Int;
  public final bMask:Int;
  public final aMask:Int;
  public final bytesPerPixel:Int;

  public function new(compressed:Bool, pixelFlags:Int, fourCC:Int, bitCount:Int, rMask:Int, gMask:Int, bMask:Int, aMask:Int, bytesPerPixel:Int) {
    this.compressed = compressed;
    this.pixelFlags = pixelFlags;
    this.fourCC = fourCC;
    this.bitCount = bitCount;
    this.rMask = rMask;
    this.gMask = gMask;
    this.bMask = bMask;
    this.aMask = aMask;
    this.bytesPerPixel = bytesPerPixel;
  }
}
