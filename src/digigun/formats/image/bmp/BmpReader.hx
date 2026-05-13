package digigun.formats.image.bmp;

import digigun.formats.FormatError;
import digigun.formats.FormatErrorCode;
import digigun.formats.FormatReader;
import digigun.formats.FormatResult;
import digigun.formats.image.ImageSize;
import digigun.formats.image.PixelFormats;
import digigun.formats.image.TextureData;
import haxe.io.Bytes;

/**
 * Parses a practical uncompressed BMP subset backed by `BITMAPINFOHEADER`.
 */
class BmpReader implements FormatReader<Bytes, TextureData> {
  static inline var FILE_HEADER_SIZE = 14;
  static inline var INFO_HEADER_SIZE = 40;

  /**
   * Creates a new BMP reader.
   */
  public function new() {}

  /**
   * Parses 24-bit and 32-bit uncompressed BMP files into a top-down texture.
   */
  public function read(input:Bytes):FormatResult<TextureData> {
    if (input.length < FILE_HEADER_SIZE + INFO_HEADER_SIZE) {
      return failure(FormatErrorCode.InvalidInput, "BMP file is too small.");
    }

    if (input.get(0) != "B".code || input.get(1) != "M".code) {
      return failure(FormatErrorCode.InvalidInput, "BMP signature is missing.");
    }

    var pixelOffset = readUInt32LE(input, 10);
    var headerSize = readUInt32LE(input, 14);
    if (headerSize != INFO_HEADER_SIZE) {
      return failure(FormatErrorCode.UnsupportedFeature, 'Only BITMAPINFOHEADER (${INFO_HEADER_SIZE} bytes) is supported.');
    }

    var width = readInt32LE(input, 18);
    var heightSigned = readInt32LE(input, 22);
    var planes = readUInt16LE(input, 26);
    var bitsPerPixel = readUInt16LE(input, 28);
    var compression = readUInt32LE(input, 30);

    if (width <= 0 || heightSigned == 0) {
      return failure(FormatErrorCode.InvalidStructure, "BMP dimensions must be non-zero.");
    }

    if (planes != 1) {
      return failure(FormatErrorCode.InvalidStructure, "BMP must declare exactly one color plane.");
    }

    if (compression != 0) {
      return failure(FormatErrorCode.UnsupportedFeature, "Only uncompressed BI_RGB BMP files are supported.");
    }

    var bytesPerPixel = switch (bitsPerPixel) {
      case 24:
        3;
      case 32:
        4;
      default:
        return failure(FormatErrorCode.UnsupportedFeature, 'Only 24-bit and 32-bit BMP files are supported, got ${bitsPerPixel}.');
    };

    var height = heightSigned < 0 ? -heightSigned : heightSigned;
    var rowBytes = width * bytesPerPixel;
    var paddedRowBytes = ((rowBytes + 3) >> 2) << 2;
    var requiredLength = pixelOffset + paddedRowBytes * height;
    if (requiredLength > input.length) {
      return failure(FormatErrorCode.InvalidStructure, "BMP pixel data is truncated.");
    }

    var pixelBytes = Bytes.alloc(rowBytes * height);
    var topDown = heightSigned < 0;
    for (y in 0...height) {
      var sourceRow = topDown ? y : (height - 1 - y);
      pixelBytes.blit(y * rowBytes, input, pixelOffset + sourceRow * paddedRowBytes, rowBytes);
    }

    var format = bitsPerPixel == 24 ? PixelFormats.BGR8_UNORM : PixelFormats.BGRA8_UNORM;
    return Success(TextureData.fromBytes2D(new ImageSize(width, height), format, pixelBytes));
  }

  function failure(code:FormatErrorCode, message:String):FormatResult<TextureData> {
    return Failure(new FormatError(code, message, null, BmpFormat.id));
  }

  static function readUInt16LE(bytes:Bytes, offset:Int):Int {
    return bytes.get(offset) | (bytes.get(offset + 1) << 8);
  }

  static function readUInt32LE(bytes:Bytes, offset:Int):Int {
    return bytes.get(offset)
      | (bytes.get(offset + 1) << 8)
      | (bytes.get(offset + 2) << 16)
      | (bytes.get(offset + 3) << 24);
  }

  static function readInt32LE(bytes:Bytes, offset:Int):Int {
    return readUInt32LE(bytes, offset);
  }
}
