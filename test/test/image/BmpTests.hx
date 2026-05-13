package test.image;

import digigun.formats.FormatErrorCode;
import digigun.formats.image.ImageSize;
import digigun.formats.image.PixelFormats;
import digigun.formats.image.TextureData;
import digigun.formats.image.bmp.BmpCodec;
import haxe.io.Bytes;
import test.Assertions;
import test.FixtureTools;

class BmpTests {
  public static function run():Void {
    testBmpFixtureParsing();
    testBmpRgbRoundTrip();
    testBmpRgbaRoundTrip();
    testInvalidBmp();
  }

  static function testBmpFixtureParsing():Void {
    var codec = new BmpCodec();
    var bytes = FixtureTools.bytes("image/bmp/parse_2x2_24.hex");

    switch (codec.read(bytes)) {
      case Success(texture):
        Assertions.assertEquals("bmp width", 2, texture.size.width);
        Assertions.assertEquals("bmp height", 2, texture.size.height);
        Assertions.assertEquals("bmp format", PixelFormats.BGR8_UNORM.id, texture.format.id);
        Assertions.assertEquals("bmp pixel bytes", "0000ff00ff00ff0000ffffff", texture.getPrimaryMipLevel().data.toHex());
      case Failure(error):
        Assertions.fail('Expected BMP parse to succeed: ${error.toString()}');
    }
  }

  static function testBmpRgbRoundTrip():Void {
    var texture = TextureData.fromBytes2D(
      new ImageSize(2, 2),
      PixelFormats.RGB8_UNORM,
      Bytes.ofHex("ff000000ff000000ffffffff")
    );
    var codec = new BmpCodec();

    var encoded = switch (codec.write(texture)) {
      case Success(bytes):
        bytes;
      case Failure(error):
        Assertions.fail('Expected BMP RGB write to succeed: ${error.toString()}');
        Bytes.alloc(0);
    };

    Assertions.assertEquals("bmp fixture serialize", FixtureTools.hex("image/bmp/parse_2x2_24.hex"), encoded.toHex().toLowerCase());

    switch (codec.read(encoded)) {
      case Success(parsed):
        Assertions.assertEquals("bmp rgb round trip format", PixelFormats.BGR8_UNORM.id, parsed.format.id);
        Assertions.assertEquals("bmp rgb round trip bytes", "0000ff00ff00ff0000ffffff", parsed.getPrimaryMipLevel().data.toHex());
      case Failure(error):
        Assertions.fail('Expected BMP RGB round trip parse to succeed: ${error.toString()}');
    }
  }

  static function testBmpRgbaRoundTrip():Void {
    var texture = TextureData.fromBytes2D(
      new ImageSize(1, 1),
      PixelFormats.RGBA8_UNORM,
      Bytes.ofHex("11223344")
    );
    var codec = new BmpCodec();

    switch (codec.write(texture)) {
      case Success(encoded):
        switch (codec.read(encoded)) {
          case Success(parsed):
            Assertions.assertEquals("bmp rgba width", 1, parsed.size.width);
            Assertions.assertEquals("bmp rgba format", PixelFormats.BGRA8_UNORM.id, parsed.format.id);
            Assertions.assertEquals("bmp rgba bytes", "33221144", parsed.getPrimaryMipLevel().data.toHex());
          case Failure(error):
            Assertions.fail('Expected BMP RGBA round trip parse to succeed: ${error.toString()}');
        }
      case Failure(error):
        Assertions.fail('Expected BMP RGBA write to succeed: ${error.toString()}');
    }
  }

  static function testInvalidBmp():Void {
    var codec = new BmpCodec();
    switch (codec.read(Bytes.ofHex("00010203"))) {
      case Failure(error):
        Assertions.assertEquals("invalid bmp code", FormatErrorCode.InvalidInput, error.code);
      case Success(_):
        Assertions.fail("Expected invalid BMP bytes to fail.");
    }
  }
}
