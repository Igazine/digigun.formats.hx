package digigun.formats.image.pvr;

import digigun.formats.FormatError;
import digigun.formats.FormatErrorCode;
import digigun.formats.FormatReader;
import digigun.formats.FormatResult;
import digigun.formats.image.ByteBuffer;
import digigun.formats.image.ImageSize;
import digigun.formats.image.MipLevel;
import digigun.formats.image.PixelFormats;
import digigun.formats.image.TextureData;
import digigun.formats.image.TextureDimension;
import digigun.formats.image.internal.BinaryTools;
import haxe.io.Bytes;

class PvrReader implements FormatReader<Bytes, TextureData> {
  static inline var VERSION = 0x03525650;

  public function new() {}

  public function read(input:Bytes):FormatResult<TextureData> {
    if (input.length < 52) {
      return failure(FormatErrorCode.InvalidInput, "PVR file is too small.");
    }

    if (BinaryTools.readUInt32LE(input, 0) != VERSION) {
      return failure(FormatErrorCode.InvalidInput, "PVR version header is invalid.");
    }

    var pixelFormatLow = BinaryTools.readUInt32LE(input, 8);
    var pixelFormatHigh = BinaryTools.readUInt32LE(input, 12);
    var width = BinaryTools.readUInt32LE(input, 28);
    var height = BinaryTools.readUInt32LE(input, 24);
    var depth = BinaryTools.readUInt32LE(input, 32);
    var surfaces = BinaryTools.readUInt32LE(input, 36);
    var faces = BinaryTools.readUInt32LE(input, 40);
    var mipCount = BinaryTools.readUInt32LE(input, 44);
    var metadataSize = BinaryTools.readUInt32LE(input, 48);

    if (width <= 0 || height <= 0) {
      return failure(FormatErrorCode.InvalidStructure, "PVR dimensions must be greater than zero.");
    }

    if (pixelFormatHigh != 0) {
      return failure(FormatErrorCode.UnsupportedFeature, "Only predefined PVR pixel-format identifiers are supported.");
    }

    if (depth != 1 || surfaces != 1 || faces != 1) {
      return failure(FormatErrorCode.UnsupportedFeature, "Only simple 2D single-surface PVR textures are supported.");
    }

    var format = switch (pixelFormatLow) {
      case 3:
        PixelFormats.PVRTC1_4_RGBA_UNORM;
      default:
        return failure(FormatErrorCode.UnsupportedFeature, "Unsupported PVR pixel format.");
    }

    if (mipCount <= 0) {
      mipCount = 1;
    }

    var texture = new TextureData(TextureDimension.Texture2D, new ImageSize(width, height), format);
    var surface = texture.getOrCreatePrimarySurface();
    var offset = 52 + metadataSize;
    if (offset < 52 || offset > input.length) {
      return failure(FormatErrorCode.InvalidStructure, "PVR metadata payload is truncated.");
    }

    for (level in 0...mipCount) {
      var levelSize = texture.size.atMipLevel(level);
      var byteLength = format.byteLengthFor(levelSize);
      if (offset + byteLength > input.length) {
        return failure(FormatErrorCode.InvalidStructure, "PVR mip data is truncated.");
      }
      surface.setMipLevel(new MipLevel(level, levelSize, new ByteBuffer(input, offset, byteLength)));
      offset += byteLength;
    }

    return Success(texture);
  }

  function failure(code:FormatErrorCode, message:String):FormatResult<TextureData> {
    return Failure(new FormatError(code, message, null, PvrFormat.id));
  }
}
