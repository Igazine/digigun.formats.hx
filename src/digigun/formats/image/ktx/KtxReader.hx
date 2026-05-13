package digigun.formats.image.ktx;

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

class KtxReader implements FormatReader<Bytes, TextureData> {
  static final IDENTIFIER = Bytes.ofHex("ab4b5458203131bb0d0a1a0a");

  public function new() {}

  public function read(input:Bytes):FormatResult<TextureData> {
    if (input.length < 64) {
      return failure(FormatErrorCode.InvalidInput, "KTX file is too small.");
    }

    for (index in 0...IDENTIFIER.length) {
      if (input.get(index) != IDENTIFIER.get(index)) {
        return failure(FormatErrorCode.InvalidInput, "KTX identifier is invalid.");
      }
    }

    var littleEndian = switch (BinaryTools.readUInt32LE(input, 12)) {
      case 0x04030201:
        true;
      case 0x01020304:
        false;
      default:
        return failure(FormatErrorCode.InvalidInput, "KTX endianness marker is invalid.");
    }

    var readUInt32 = littleEndian ? BinaryTools.readUInt32LE : BinaryTools.readUInt32BE;
    var glType = readUInt32(input, 16);
    var glFormat = readUInt32(input, 24);
    var glInternalFormat = readUInt32(input, 28);
    var pixelWidth = readUInt32(input, 36);
    var pixelHeight = readUInt32(input, 40);
    var pixelDepth = readUInt32(input, 44);
    var arrayElements = readUInt32(input, 48);
    var faces = readUInt32(input, 52);
    var mipLevels = readUInt32(input, 56);
    var keyValueBytes = readUInt32(input, 60);

    if (pixelDepth != 0 || arrayElements != 0 || faces != 1) {
      return failure(FormatErrorCode.UnsupportedFeature, "Only 2D non-array single-face KTX textures are supported.");
    }

    if (mipLevels == 0) {
      mipLevels = 1;
    }

    var format = resolveFormat(glType, glFormat, glInternalFormat);
    if (format == null) {
      return failure(FormatErrorCode.UnsupportedFeature, "Unsupported KTX internal format.");
    }

    var texture = new TextureData(TextureDimension.Texture2D, new ImageSize(pixelWidth, pixelHeight), format);
    var surface = texture.getOrCreatePrimarySurface();
    var offset = 64 + keyValueBytes;
    for (level in 0...mipLevels) {
      var imageSize = readUInt32(input, offset);
      offset += 4;
      if (offset + imageSize > input.length) {
        return failure(FormatErrorCode.InvalidStructure, "KTX mip payload is truncated.");
      }
      var levelSize = texture.size.atMipLevel(level);
      surface.setMipLevel(new MipLevel(level, levelSize, new ByteBuffer(input, offset, imageSize)));
      offset += BinaryTools.align4(imageSize);
    }

    return Success(texture);
  }

  function resolveFormat(glType:Int, glFormat:Int, glInternalFormat:Int):Null<PixelFormat> {
    return switch (glInternalFormat) {
      case 0x822b if (glType == 0x1401 && glFormat == 0x8227):
        PixelFormats.RG8_UNORM;
      case 0x8051 if (glType == 0x1401 && glFormat == 0x1907):
        PixelFormats.RGB8_UNORM;
      case 0x8058 if (glType == 0x1401 && glFormat == 0x1908):
        PixelFormats.RGBA8_UNORM;
      case 0x83f0 if (glType == 0 && glFormat == 0):
        PixelFormats.BC1_RGB_UNORM;
      case 0x83f3 if (glType == 0 && glFormat == 0):
        PixelFormats.BC3_RGBA_UNORM;
      case 0x8dbb if (glType == 0 && glFormat == 0):
        PixelFormats.BC4_R_UNORM;
      case 0x8dbd if (glType == 0 && glFormat == 0):
        PixelFormats.BC5_RG_UNORM;
      case 0x9274 if (glType == 0 && glFormat == 0):
        PixelFormats.ETC2_RGB8_UNORM;
      case 0x9278 if (glType == 0 && glFormat == 0):
        PixelFormats.ETC2_RGBA8_UNORM;
      case 0x9270 if (glType == 0 && glFormat == 0):
        PixelFormats.EAC_R11_UNORM;
      case 0x9272 if (glType == 0 && glFormat == 0):
        PixelFormats.EAC_RG11_UNORM;
      default:
        null;
    };
  }

  function failure(code:FormatErrorCode, message:String):FormatResult<TextureData> {
    return Failure(new FormatError(code, message, null, KtxFormat.id));
  }
}
