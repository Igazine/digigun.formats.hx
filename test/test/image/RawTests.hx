package test.image;

import digigun.formats.FormatErrorCode;
import digigun.formats.image.ImageSize;
import digigun.formats.image.PixelFormats;
import digigun.formats.image.raw.RawCodec;
import digigun.formats.image.raw.RawImageSpec;
import haxe.io.Bytes;
import test.Assertions;
import test.FixtureTools;

class RawTests {
  public static function run():Void {
    testRawRgbaRoundTrip();
    testRawCompressedRoundTrip();
    testInvalidRawLength();
  }

  static function testRawRgbaRoundTrip():Void {
    var spec = new RawImageSpec(new ImageSize(2, 1), PixelFormats.RGBA8_UNORM);
    var codec = new RawCodec(spec);
    var bytes = FixtureTools.bytes("image/raw/rgba_2x1.hex");

    switch (codec.read(bytes)) {
      case Success(texture):
        Assertions.assertEquals("raw rgba width", 2, texture.size.width);
        Assertions.assertEquals("raw rgba format", PixelFormats.RGBA8_UNORM.id, texture.format.id);
        Assertions.assertEquals("raw rgba primary bytes", bytes.toHex().toLowerCase(), texture.getPrimaryMipLevel().data.toHex());
      case Failure(error):
        Assertions.fail('Expected RAW RGBA parse to succeed: ${error.toString()}');
    }

    var texture = digigun.formats.image.TextureData.fromBytes2D(new ImageSize(2, 1), PixelFormats.RGBA8_UNORM, bytes);
    switch (codec.write(texture)) {
      case Success(output):
        Assertions.assertEquals("raw rgba serialize", bytes.toHex().toLowerCase(), output.toHex().toLowerCase());
      case Failure(error):
        Assertions.fail('Expected RAW RGBA write to succeed: ${error.toString()}');
    }
  }

  static function testRawCompressedRoundTrip():Void {
    var spec = new RawImageSpec(new ImageSize(4, 4), PixelFormats.BC1_RGB_UNORM);
    var codec = new RawCodec(spec);
    var bytes = FixtureTools.bytes("image/raw/bc1_4x4.hex");

    switch (codec.read(bytes)) {
      case Success(texture):
        Assertions.assertTrue("raw compressed format", texture.format.isCompressed());
        Assertions.assertEquals("raw compressed byte size", 8, texture.totalByteLength());
      case Failure(error):
        Assertions.fail('Expected RAW compressed parse to succeed: ${error.toString()}');
    }

    var texture = digigun.formats.image.TextureData.fromBytes2D(new ImageSize(4, 4), PixelFormats.BC1_RGB_UNORM, bytes);
    switch (codec.write(texture)) {
      case Success(output):
        Assertions.assertEquals("raw compressed serialize", bytes.toHex().toLowerCase(), output.toHex().toLowerCase());
      case Failure(error):
        Assertions.fail('Expected RAW compressed write to succeed: ${error.toString()}');
    }
  }

  static function testInvalidRawLength():Void {
    var codec = new RawCodec(new RawImageSpec(new ImageSize(2, 2), PixelFormats.RGBA8_UNORM));
    switch (codec.read(Bytes.alloc(4))) {
      case Failure(error):
        Assertions.assertEquals("invalid raw code", FormatErrorCode.InvalidInput, error.code);
      case Success(_):
        Assertions.fail("Expected RAW byte length mismatch to fail.");
    }
  }
}
