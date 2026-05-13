package test.image;

import digigun.formats.FormatErrorCode;
import digigun.formats.image.ImageSize;
import digigun.formats.image.PixelFormats;
import digigun.formats.image.TextureData;
import digigun.formats.image.tga.TgaCodec;
import haxe.io.Bytes;
import test.Assertions;
import test.FixtureTools;

class TgaTests {
  public static function run():Void {
    testTgaBgrRoundTrip();
    testTgaGrayscaleRoundTrip();
    testTgaRleRoundTrip();
    testTgaColorMappedUnsupported();
    testInvalidTga();
  }

  static function testTgaBgrRoundTrip():Void {
    var texture = TextureData.fromBytes2D(new ImageSize(2, 1), PixelFormats.BGR8_UNORM, Bytes.ofHex("112233445566"));
    var codec = new TgaCodec();

    switch (codec.write(texture)) {
      case Success(encoded):
        switch (codec.read(encoded)) {
          case Success(parsed):
            Assertions.assertEquals("tga format", PixelFormats.BGR8_UNORM.id, parsed.format.id);
            Assertions.assertEquals("tga bytes", "112233445566", parsed.getPrimaryMipLevel().data.toHex());
          case Failure(error):
            Assertions.fail('Expected TGA parse to succeed: ${error.toString()}');
        }
      case Failure(error):
        Assertions.fail('Expected TGA write to succeed: ${error.toString()}');
    }
  }

  static function testTgaGrayscaleRoundTrip():Void {
    var texture = TextureData.fromBytes2D(new ImageSize(2, 1), PixelFormats.R8_UNORM, Bytes.ofHex("1020"));
    var codec = new TgaCodec();
    switch (codec.write(texture)) {
      case Success(encoded):
        switch (codec.read(encoded)) {
          case Success(parsed):
            Assertions.assertEquals("tga gray format", PixelFormats.R8_UNORM.id, parsed.format.id);
            Assertions.assertEquals("tga gray bytes", "1020", parsed.getPrimaryMipLevel().data.toHex());
          case Failure(error):
            Assertions.fail('Expected grayscale TGA parse to succeed: ${error.toString()}');
        }
      case Failure(error):
        Assertions.fail('Expected grayscale TGA write to succeed: ${error.toString()}');
    }
  }

  static function testTgaRleRoundTrip():Void {
    var texture = TextureData.fromBytes2D(new ImageSize(2, 1), PixelFormats.R8_UNORM, Bytes.ofHex("7f7f"));
    var codec = new TgaCodec();

    var encoded = switch (codec.write(texture)) {
      case Success(bytes):
        bytes;
      case Failure(error):
        Assertions.fail('Expected RLE TGA write to succeed: ${error.toString()}');
        Bytes.alloc(0);
    };

    Assertions.assertEquals("tga rle fixture", FixtureTools.hex("image/tga/parse_2x1_gray_rle.hex"), encoded.toHex().toLowerCase());

    switch (codec.read(encoded)) {
      case Success(parsed):
        Assertions.assertEquals("tga rle format", PixelFormats.R8_UNORM.id, parsed.format.id);
        Assertions.assertEquals("tga rle bytes", "7f7f", parsed.getPrimaryMipLevel().data.toHex());
      case Failure(error):
        Assertions.fail('Expected RLE TGA parse to succeed: ${error.toString()}');
    }
  }

  static function testInvalidTga():Void {
    var codec = new TgaCodec();
    switch (codec.read(Bytes.ofHex("000100"))) {
      case Failure(error):
        Assertions.assertEquals("invalid tga code", FormatErrorCode.InvalidInput, error.code);
      case Success(_):
        Assertions.fail("Expected invalid TGA bytes to fail.");
    }
  }

  static function testTgaColorMappedUnsupported():Void {
    var codec = new TgaCodec();
    switch (codec.read(Bytes.ofHex("000100000000000000000000000000000000"))) {
      case Failure(error):
        Assertions.assertEquals("tga color-mapped unsupported code", FormatErrorCode.UnsupportedFeature, error.code);
      case Success(_):
        Assertions.fail("Expected color-mapped TGA bytes to fail.");
    }
  }
}
