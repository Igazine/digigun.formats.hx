package digigun.formats.image.tga;

import digigun.formats.FormatError;
import digigun.formats.FormatErrorCode;
import digigun.formats.FormatReader;
import digigun.formats.FormatResult;
import digigun.formats.image.ImageSize;
import digigun.formats.image.PixelFormats;
import digigun.formats.image.TextureData;
import haxe.io.Bytes;

class TgaReader implements FormatReader<Bytes, TextureData> {
  public function new() {}

  public function read(input:Bytes):FormatResult<TextureData> {
    if (input.length < 18) {
      return failure(FormatErrorCode.InvalidInput, "TGA file is too small.");
    }

    var idLength = input.get(0);
    var colorMapType = input.get(1);
    var imageType = input.get(2);
    var width = input.get(12) | (input.get(13) << 8);
    var height = input.get(14) | (input.get(15) << 8);
    var pixelDepth = input.get(16);
    var descriptor = input.get(17);

    if (colorMapType != 0) {
      return failure(FormatErrorCode.UnsupportedFeature, "Color-mapped TGA files are not supported.");
    }

    var dataOffset = 18 + idLength;
    var bytesPerPixel = switch (imageType) {
      case 2 if (pixelDepth == 24):
        3;
      case 2 if (pixelDepth == 32):
        4;
      case 3 if (pixelDepth == 8):
        1;
      case 10 if (pixelDepth == 24):
        3;
      case 10 if (pixelDepth == 32):
        4;
      case 11 if (pixelDepth == 8):
        1;
      default:
        return failure(FormatErrorCode.UnsupportedFeature, "Only uncompressed 8/24/32-bit and RLE 8/24/32-bit TGA files are supported.");
    }

    var dataLength = width * height * bytesPerPixel;
    var pixelBytes = switch (imageType) {
      case 2, 3:
        if (dataOffset + dataLength > input.length) {
          return failure(FormatErrorCode.InvalidStructure, "TGA pixel data is truncated.");
        }
        var output = Bytes.alloc(dataLength);
        output.blit(0, input, dataOffset, dataLength);
        output;
      case 10, 11:
        var decoded = decodeRlePixels(input, dataOffset, dataLength, bytesPerPixel);
        switch (decoded) {
          case Failure(error):
            return Failure(error);
          case Success(bytes):
            bytes;
        }
      default:
        null;
    };

    var topOrigin = (descriptor & 0x20) != 0;
    var rowBytes = width * bytesPerPixel;
    var output = Bytes.alloc(dataLength);
    for (y in 0...height) {
      var sourceRow = topOrigin ? y : (height - 1 - y);
      output.blit(y * rowBytes, pixelBytes, sourceRow * rowBytes, rowBytes);
    }

    var format = switch (bytesPerPixel) {
      case 1:
        PixelFormats.R8_UNORM;
      case 3:
        PixelFormats.BGR8_UNORM;
      case 4:
        PixelFormats.BGRA8_UNORM;
      default:
        null;
    };

    return Success(TextureData.fromBytes2D(new ImageSize(width, height), format, output));
  }

  function decodeRlePixels(input:Bytes, dataOffset:Int, dataLength:Int, bytesPerPixel:Int):FormatResult<Bytes> {
    var output = Bytes.alloc(dataLength);
    var cursor = dataOffset;
    var writeOffset = 0;

    while (writeOffset < dataLength) {
      if (cursor >= input.length) {
        return failureBytes(FormatErrorCode.InvalidStructure, "TGA RLE pixel data is truncated.");
      }

      var packetHeader = input.get(cursor++);
      var packetLength = (packetHeader & 0x7f) + 1;
      var packetBytes = packetLength * bytesPerPixel;
      if (writeOffset + packetBytes > dataLength) {
        return failureBytes(FormatErrorCode.InvalidStructure, "TGA RLE packet exceeds the expected image length.");
      }

      if ((packetHeader & 0x80) != 0) {
        if (cursor + bytesPerPixel > input.length) {
          return failureBytes(FormatErrorCode.InvalidStructure, "TGA RLE run packet is truncated.");
        }

        for (index in 0...packetLength) {
          output.blit(writeOffset + index * bytesPerPixel, input, cursor, bytesPerPixel);
        }
        cursor += bytesPerPixel;
      } else {
        if (cursor + packetBytes > input.length) {
          return failureBytes(FormatErrorCode.InvalidStructure, "TGA RLE raw packet is truncated.");
        }

        output.blit(writeOffset, input, cursor, packetBytes);
        cursor += packetBytes;
      }

      writeOffset += packetBytes;
    }

    return Success(output);
  }

  function failure(code:FormatErrorCode, message:String):FormatResult<TextureData> {
    return Failure(new FormatError(code, message, null, TgaFormat.id));
  }

  function failureBytes(code:FormatErrorCode, message:String):FormatResult<Bytes> {
    return Failure(new FormatError(code, message, null, TgaFormat.id));
  }
}
