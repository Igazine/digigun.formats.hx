package test.image;

import digigun.formats.FormatErrorCode;
import digigun.formats.image.ImageSize;
import digigun.formats.image.PixelFormats;
import digigun.formats.image.TextureData;
import digigun.formats.image.tiff.TiffCodec;
import haxe.io.Bytes;
import test.Assertions;
import test.FixtureTools;

class TiffTests {
  public static function run():Void {
    testTiffFixtureParsing();
    testTiffRgbRoundTrip();
    testTiffRgbaRoundTrip();
    testInvalidTiff();
  }

  static function testTiffFixtureParsing():Void {
    var codec = new TiffCodec();
    var bytes = FixtureTools.bytes("image/tiff/parse_2x2_rgb.hex");

    switch (codec.read(bytes)) {
      case Success(texture):
        Assertions.assertEquals("tiff width", 2, texture.size.width);
        Assertions.assertEquals("tiff height", 2, texture.size.height);
        Assertions.assertEquals("tiff format", PixelFormats.RGB8_UNORM.id, texture.format.id);
        Assertions.assertEquals("tiff pixel bytes", "ff000000ff000000ffffffff", texture.getPrimaryMipLevel().data.toHex());
      case Failure(error):
        Assertions.fail('Expected TIFF parse to succeed: ${error.toString()}');
    }
  }

  static function testTiffRgbRoundTrip():Void {
    var texture = TextureData.fromBytes2D(
      new ImageSize(2, 2),
      PixelFormats.RGB8_UNORM,
      Bytes.ofHex("ff000000ff000000ffffffff")
    );
    var codec = new TiffCodec();

    var encoded = switch (codec.write(texture)) {
      case Success(bytes):
        bytes;
      case Failure(error):
        Assertions.fail('Expected TIFF RGB write to succeed: ${error.toString()}');
        Bytes.alloc(0);
    };

    Assertions.assertEquals("tiff fixture serialize", FixtureTools.hex("image/tiff/parse_2x2_rgb.hex"), encoded.toHex().toLowerCase());

    switch (codec.read(encoded)) {
      case Success(parsed):
        Assertions.assertEquals("tiff rgb round trip bytes", "ff000000ff000000ffffffff", parsed.getPrimaryMipLevel().data.toHex());
      case Failure(error):
        Assertions.fail('Expected TIFF RGB round trip parse to succeed: ${error.toString()}');
    }
  }

  static function testTiffRgbaRoundTrip():Void {
    var texture = TextureData.fromBytes2D(
      new ImageSize(1, 1),
      PixelFormats.RGBA8_UNORM,
      Bytes.ofHex("11223344")
    );
    var codec = new TiffCodec();

    switch (codec.write(texture)) {
      case Success(encoded):
        switch (codec.read(encoded)) {
          case Success(parsed):
            Assertions.assertEquals("tiff rgba width", 1, parsed.size.width);
            Assertions.assertEquals("tiff rgba format", PixelFormats.RGBA8_UNORM.id, parsed.format.id);
            Assertions.assertEquals("tiff rgba bytes", "11223344", parsed.getPrimaryMipLevel().data.toHex());
          case Failure(error):
            Assertions.fail('Expected TIFF RGBA round trip parse to succeed: ${error.toString()}');
        }
      case Failure(error):
        Assertions.fail('Expected TIFF RGBA write to succeed: ${error.toString()}');
    }
  }

  static function testInvalidTiff():Void {
    var codec = new TiffCodec();
    switch (codec.read(Bytes.ofHex("49492a000800"))) {
      case Failure(error):
        Assertions.assertEquals("invalid tiff code", FormatErrorCode.InvalidInput, error.code);
      case Success(_):
        Assertions.fail("Expected invalid TIFF bytes to fail.");
    }
  }
}
