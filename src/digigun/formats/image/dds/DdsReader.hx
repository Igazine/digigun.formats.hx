package digigun.formats.image.dds;

import digigun.formats.FormatError;
import digigun.formats.FormatErrorCode;
import digigun.formats.FormatReader;
import digigun.formats.FormatResult;
import digigun.formats.image.ByteBuffer;
import digigun.formats.image.ImageSize;
import digigun.formats.image.MipLevel;
import digigun.formats.image.PixelFormat;
import digigun.formats.image.PixelFormats;
import digigun.formats.image.TextureData;
import digigun.formats.image.TextureDimension;
import digigun.formats.image.internal.BinaryTools;
import haxe.io.Bytes;

/**
 * Parses a practical DDS subset with one 2D texture and optional mipmaps.
 */
class DdsReader implements FormatReader<Bytes, TextureData> {
  static inline var DDS_MAGIC = 0x20534444;
  static inline var DDPF_ALPHA = 0x1;
  static inline var DDPF_FOURCC = 0x4;
  static inline var DDPF_RGB = 0x40;

  public function new() {}

  public function read(input:Bytes):FormatResult<TextureData> {
    if (input.length < 128) {
      return failure(FormatErrorCode.InvalidInput, "DDS file is too small.");
    }

    if (BinaryTools.readUInt32LE(input, 0) != DDS_MAGIC) {
      return failure(FormatErrorCode.InvalidInput, "DDS signature is missing.");
    }

    if (BinaryTools.readUInt32LE(input, 4) != 124) {
      return failure(FormatErrorCode.InvalidStructure, "DDS header size must be 124.");
    }

    var height = BinaryTools.readUInt32LE(input, 12);
    var width = BinaryTools.readUInt32LE(input, 16);
    var mipCount = BinaryTools.readUInt32LE(input, 28);
    if (mipCount <= 0) {
      mipCount = 1;
    }

    var pixelFormatFlags = BinaryTools.readUInt32LE(input, 80);
    var fourCC = BinaryTools.readUInt32LE(input, 84);
    var rgbBitCount = BinaryTools.readUInt32LE(input, 88);
    var rMask = BinaryTools.readUInt32LE(input, 92);
    var gMask = BinaryTools.readUInt32LE(input, 96);
    var bMask = BinaryTools.readUInt32LE(input, 100);
    var aMask = BinaryTools.readUInt32LE(input, 104);

    var format = resolveFormat(pixelFormatFlags, fourCC, rgbBitCount, rMask, gMask, bMask, aMask);
    if (format == null) {
      return failure(FormatErrorCode.UnsupportedFeature, "Unsupported DDS pixel format.");
    }

    var texture = new TextureData(TextureDimension.Texture2D, new ImageSize(width, height), format);
    var surface = texture.getOrCreatePrimarySurface();
    var dataOffset = 128;
    for (level in 0...mipCount) {
      var levelSize = texture.size.atMipLevel(level);
      var byteLength = format.byteLengthFor(levelSize);
      if (dataOffset + byteLength > input.length) {
        return failure(FormatErrorCode.InvalidStructure, "DDS mip data is truncated.");
      }
      surface.setMipLevel(new MipLevel(level, levelSize, new ByteBuffer(input, dataOffset, byteLength)));
      dataOffset += byteLength;
    }

    return Success(texture);
  }

  function resolveFormat(flags:Int, fourCC:Int, bitCount:Int, rMask:Int, gMask:Int, bMask:Int, aMask:Int):Null<PixelFormat> {
    if ((flags & DDPF_FOURCC) != 0) {
      var dxt1 = BinaryTools.fourCC("DXT1");
      var dxt5 = BinaryTools.fourCC("DXT5");
      var ati1 = BinaryTools.fourCC("ATI1");
      var ati2 = BinaryTools.fourCC("ATI2");
      if (fourCC == dxt1) {
        return PixelFormats.BC1_RGB_UNORM;
      }
      if (fourCC == dxt5) {
        return PixelFormats.BC3_RGBA_UNORM;
      }
      if (fourCC == ati1) {
        return PixelFormats.BC4_R_UNORM;
      }
      if (fourCC == ati2) {
        return PixelFormats.BC5_RG_UNORM;
      }
      return null;
    }

    if ((flags & DDPF_RGB) == 0) {
      return null;
    }

    return switch (bitCount) {
      case 24 if (rMask == 0x00ff0000 && gMask == 0x0000ff00 && bMask == 0x000000ff):
        PixelFormats.BGR8_UNORM;
      case 24 if (rMask == 0x000000ff && gMask == 0x0000ff00 && bMask == 0x00ff0000):
        PixelFormats.RGB8_UNORM;
      case 32 if (rMask == 0x00ff0000 && gMask == 0x0000ff00 && bMask == 0x000000ff && aMask == 0xff000000):
        PixelFormats.BGRA8_UNORM;
      case 32 if (rMask == 0x000000ff && gMask == 0x0000ff00 && bMask == 0x00ff0000 && aMask == 0xff000000):
        PixelFormats.RGBA8_UNORM;
      default:
        null;
    };
  }

  function failure(code:FormatErrorCode, message:String):FormatResult<TextureData> {
    return Failure(new FormatError(code, message, null, DdsFormat.id));
  }
}
