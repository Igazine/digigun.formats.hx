package digigun.formats.image.ppm;

import digigun.formats.FormatError;
import digigun.formats.FormatErrorCode;
import digigun.formats.FormatReader;
import digigun.formats.FormatResult;
import digigun.formats.image.ImageSize;
import digigun.formats.image.PixelFormats;
import digigun.formats.image.TextureData;
import haxe.io.Bytes;

class PpmReader implements FormatReader<Bytes, TextureData> {
  public function new() {}

  public function read(input:Bytes):FormatResult<TextureData> {
    if (input.length < 3 || input.get(0) != "P".code) {
      return failure(FormatErrorCode.InvalidInput, "PPM/PGM signature is missing.");
    }

    var signature = String.fromCharCode(input.get(1));
    if (signature != "5" && signature != "6") {
      return failure(FormatErrorCode.UnsupportedFeature, "Only binary P5 and P6 formats are supported.");
    }

    var offset = 2;
    var width = readToken(input, offset);
    offset = width.next;
    var height = readToken(input, offset);
    offset = height.next;
    var maxValue = readToken(input, offset);
    offset = skipWhitespaceAndComments(input, maxValue.next);

    if (Std.parseInt(maxValue.value) != 255) {
      return failure(FormatErrorCode.UnsupportedFeature, "Only max value 255 is supported.");
    }

    var widthValue = Std.parseInt(width.value);
    var heightValue = Std.parseInt(height.value);
    var bytesPerPixel = signature == "5" ? 1 : 3;
    var dataLength = widthValue * heightValue * bytesPerPixel;
    if (offset + dataLength > input.length) {
      return failure(FormatErrorCode.InvalidStructure, "PPM/PGM pixel data is truncated.");
    }

    var pixelBytes = input.sub(offset, dataLength);
    var format = signature == "5" ? PixelFormats.R8_UNORM : PixelFormats.RGB8_UNORM;
    return Success(TextureData.fromBytes2D(new ImageSize(widthValue, heightValue), format, pixelBytes));
  }

  function readToken(input:Bytes, offset:Int):{value:String, next:Int} {
    var current = skipWhitespaceAndComments(input, offset);
    var start = current;
    while (current < input.length && !isWhitespace(input.get(current)) && input.get(current) != "#".code) {
      current++;
    }
    return { value: input.getString(start, current - start), next: current };
  }

  function skipWhitespaceAndComments(input:Bytes, offset:Int):Int {
    var current = offset;
    while (current < input.length) {
      var value = input.get(current);
      if (value == "#".code) {
        while (current < input.length && input.get(current) != "\n".code) {
          current++;
        }
      } else if (isWhitespace(value)) {
        current++;
      } else {
        break;
      }
    }
    return current;
  }

  inline function isWhitespace(value:Int):Bool {
    return value == " ".code || value == "\n".code || value == "\r".code || value == "\t".code;
  }

  function failure(code:FormatErrorCode, message:String):FormatResult<TextureData> {
    return Failure(new FormatError(code, message, null, PpmFormat.id));
  }
}
