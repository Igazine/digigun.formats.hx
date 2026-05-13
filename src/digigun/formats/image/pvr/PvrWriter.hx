package digigun.formats.image.pvr;

import digigun.formats.FormatError;
import digigun.formats.FormatErrorCode;
import digigun.formats.FormatResult;
import digigun.formats.FormatWriter;
import digigun.formats.image.TextureData;
import digigun.formats.image.TextureDimension;
import digigun.formats.image.internal.BinaryTools;
import haxe.io.Bytes;

class PvrWriter implements FormatWriter<TextureData, Bytes> {
  static inline var VERSION = 0x03525650;

  public function new() {}

  public function write(value:TextureData):FormatResult<Bytes> {
    if (value.dimension != TextureDimension.Texture2D) {
      return failure("PVR writing currently supports only 2D textures.");
    }

    if (value.format.id != "pvrtc1-4-rgba-unorm") {
      return failure("PVR writing currently supports only PVRTC1 4bpp RGBA textures.");
    }

    var surface = value.getPrimarySurface();
    if (surface == null || surface.mipLevels.length == 0) {
      return failure("PVR texture has no mip levels.");
    }

    var totalLength = 52;
    for (mip in surface.mipLevels) {
      totalLength += mip.data.length;
    }
    var output = Bytes.alloc(totalLength);
    BinaryTools.writeUInt32LE(output, 0, VERSION);
    BinaryTools.writeUInt32LE(output, 4, 0);
    BinaryTools.writeUInt32LE(output, 8, 3);
    BinaryTools.writeUInt32LE(output, 12, 0);
    BinaryTools.writeUInt32LE(output, 16, 0);
    BinaryTools.writeUInt32LE(output, 20, 0);
    BinaryTools.writeUInt32LE(output, 24, value.size.height);
    BinaryTools.writeUInt32LE(output, 28, value.size.width);
    BinaryTools.writeUInt32LE(output, 32, 1);
    BinaryTools.writeUInt32LE(output, 36, 1);
    BinaryTools.writeUInt32LE(output, 40, 1);
    BinaryTools.writeUInt32LE(output, 44, surface.mipLevels.length);
    BinaryTools.writeUInt32LE(output, 48, 0);

    var offset = 52;
    for (mip in surface.mipLevels) {
      output.blit(offset, mip.data.bytes, mip.data.offset, mip.data.length);
      offset += mip.data.length;
    }
    return Success(output);
  }

  function failure(message:String):FormatResult<Bytes> {
    return Failure(new FormatError(FormatErrorCode.InvalidInput, message, null, PvrFormat.id));
  }
}
