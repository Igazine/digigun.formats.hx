package test.image;

import digigun.formats.FormatErrorCode;
import digigun.formats.image.ImageSize;
import digigun.formats.image.PixelFormats;
import digigun.formats.image.TextureData;
import digigun.formats.image.ppm.PpmCodec;
import haxe.io.Bytes;
import test.Assertions;

class PpmTests {
  public static function run():Void {
    testPpmRoundTrip();
    testPgmRoundTrip();
    testInvalidPpm();
  }

  static function testPpmRoundTrip():Void {
    var texture = TextureData.fromBytes2D(new ImageSize(2, 1), PixelFormats.RGB8_UNORM, Bytes.ofHex("ff000000ff00"));
    var codec = new PpmCodec();
    switch (codec.write(texture)) {
      case Success(encoded):
        switch (codec.read(encoded)) {
          case Success(parsed):
            Assertions.assertEquals("ppm format", PixelFormats.RGB8_UNORM.id, parsed.format.id);
            Assertions.assertEquals("ppm bytes", "ff000000ff00", parsed.getPrimaryMipLevel().data.toHex());
          case Failure(error):
            Assertions.fail('Expected PPM parse to succeed: ${error.toString()}');
        }
      case Failure(error):
        Assertions.fail('Expected PPM write to succeed: ${error.toString()}');
    }
  }

  static function testPgmRoundTrip():Void {
    var texture = TextureData.fromBytes2D(new ImageSize(2, 1), PixelFormats.R8_UNORM, Bytes.ofHex("1020"));
    var codec = new PpmCodec();
    switch (codec.write(texture)) {
      case Success(encoded):
        switch (codec.read(encoded)) {
          case Success(parsed):
            Assertions.assertEquals("pgm format", PixelFormats.R8_UNORM.id, parsed.format.id);
            Assertions.assertEquals("pgm bytes", "1020", parsed.getPrimaryMipLevel().data.toHex());
          case Failure(error):
            Assertions.fail('Expected PGM parse to succeed: ${error.toString()}');
        }
      case Failure(error):
        Assertions.fail('Expected PGM write to succeed: ${error.toString()}');
    }
  }

  static function testInvalidPpm():Void {
    var codec = new PpmCodec();
    switch (codec.read(Bytes.ofString("P3\n1 1\n255\n0 0 0\n"))) {
      case Failure(error):
        Assertions.assertEquals("invalid ppm code", FormatErrorCode.UnsupportedFeature, error.code);
      case Success(_):
        Assertions.fail("Expected unsupported text PPM to fail.");
    }
  }
}
