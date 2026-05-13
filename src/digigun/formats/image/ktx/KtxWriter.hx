package digigun.formats.image.ktx;

import digigun.formats.FormatError;
import digigun.formats.FormatErrorCode;
import digigun.formats.FormatResult;
import digigun.formats.FormatWriter;
import digigun.formats.image.PixelFormat;
import digigun.formats.image.TextureData;
import digigun.formats.image.TextureDimension;
import digigun.formats.image.internal.BinaryTools;
import haxe.io.Bytes;

class KtxWriter implements FormatWriter<TextureData, Bytes> {
  static final IDENTIFIER = Bytes.ofHex("ab4b5458203131bb0d0a1a0a");

  public function new() {}

  public function write(value:TextureData):FormatResult<Bytes> {
    if (value.dimension != TextureDimension.Texture2D) {
      return failure("KTX writing currently supports only 2D textures.");
    }

    var surface = value.getPrimarySurface();
    if (surface == null || surface.mipLevels.length == 0) {
      return failure("KTX texture has no mip levels.");
    }

    var formatInfo = resolveFormat(value.format);
    if (formatInfo == null) {
      return failure('Unsupported KTX write format: ${value.format.id}');
    }

    var totalLength = 64;
    for (mip in surface.mipLevels) {
      totalLength += 4 + BinaryTools.align4(mip.data.length);
    }
    var output = Bytes.alloc(totalLength);
    output.blit(0, IDENTIFIER, 0, IDENTIFIER.length);

    BinaryTools.writeUInt32LE(output, 12, 0x04030201);
    BinaryTools.writeUInt32LE(output, 16, formatInfo.glType);
    BinaryTools.writeUInt32LE(output, 20, formatInfo.glTypeSize);
    BinaryTools.writeUInt32LE(output, 24, formatInfo.glFormat);
    BinaryTools.writeUInt32LE(output, 28, formatInfo.glInternalFormat);
    BinaryTools.writeUInt32LE(output, 32, formatInfo.glBaseInternalFormat);
    BinaryTools.writeUInt32LE(output, 36, value.size.width);
    BinaryTools.writeUInt32LE(output, 40, value.size.height);
    BinaryTools.writeUInt32LE(output, 44, 0);
    BinaryTools.writeUInt32LE(output, 48, 0);
    BinaryTools.writeUInt32LE(output, 52, 1);
    BinaryTools.writeUInt32LE(output, 56, surface.mipLevels.length);
    BinaryTools.writeUInt32LE(output, 60, 0);

    var offset = 64;
    for (mip in surface.mipLevels) {
      BinaryTools.writeUInt32LE(output, offset, mip.data.length);
      offset += 4;
      output.blit(offset, mip.data.bytes, mip.data.offset, mip.data.length);
      offset += BinaryTools.align4(mip.data.length);
    }
    return Success(output);
  }

  function resolveFormat(format:PixelFormat):Null<KtxWriteFormatInfo> {
    return switch (format.id) {
      case "rg8-unorm":
        new KtxWriteFormatInfo(0x1401, 1, 0x8227, 0x822b, 0x8227);
      case "rgb8-unorm":
        new KtxWriteFormatInfo(0x1401, 1, 0x1907, 0x8051, 0x1907);
      case "rgba8-unorm":
        new KtxWriteFormatInfo(0x1401, 1, 0x1908, 0x8058, 0x1908);
      case "bc1-rgb-unorm":
        new KtxWriteFormatInfo(0, 1, 0, 0x83f0, 0x1907);
      case "bc3-rgba-unorm":
        new KtxWriteFormatInfo(0, 1, 0, 0x83f3, 0x1908);
      case "bc4-r-unorm":
        new KtxWriteFormatInfo(0, 1, 0, 0x8dbb, 0x1903);
      case "bc5-rg-unorm":
        new KtxWriteFormatInfo(0, 1, 0, 0x8dbd, 0x8227);
      case "etc2-rgb8-unorm":
        new KtxWriteFormatInfo(0, 1, 0, 0x9274, 0x1907);
      case "etc2-rgba8-unorm":
        new KtxWriteFormatInfo(0, 1, 0, 0x9278, 0x1908);
      case "eac-r11-unorm":
        new KtxWriteFormatInfo(0, 1, 0, 0x9270, 0x1903);
      case "eac-rg11-unorm":
        new KtxWriteFormatInfo(0, 1, 0, 0x9272, 0x8227);
      default:
        null;
    };
  }

  function failure(message:String):FormatResult<Bytes> {
    return Failure(new FormatError(FormatErrorCode.InvalidInput, message, null, KtxFormat.id));
  }
}

private class KtxWriteFormatInfo {
  public final glType:Int;
  public final glTypeSize:Int;
  public final glFormat:Int;
  public final glInternalFormat:Int;
  public final glBaseInternalFormat:Int;

  public function new(glType:Int, glTypeSize:Int, glFormat:Int, glInternalFormat:Int, glBaseInternalFormat:Int) {
    this.glType = glType;
    this.glTypeSize = glTypeSize;
    this.glFormat = glFormat;
    this.glInternalFormat = glInternalFormat;
    this.glBaseInternalFormat = glBaseInternalFormat;
  }
}
