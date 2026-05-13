package test.image;

import digigun.formats.FormatErrorCode;
import digigun.formats.image.ByteBuffer;
import digigun.formats.image.ImageSize;
import digigun.formats.image.MipLevel;
import digigun.formats.image.PixelFormats;
import digigun.formats.image.TextureData;
import digigun.formats.image.dds.DdsCodec;
import haxe.io.Bytes;
import test.Assertions;

class DdsTests {
  public static function run():Void {
    testDdsBgraRoundTrip();
    testDdsCompressedRoundTrip();
    testDdsBc4RoundTrip();
    testDdsBc5RoundTrip();
    testDdsMipChainRoundTrip();
    testDdsUnsupportedFourCc();
    testInvalidDds();
  }

  static function testDdsBgraRoundTrip():Void {
    var texture = TextureData.fromBytes2D(new ImageSize(2, 1), PixelFormats.BGRA8_UNORM, Bytes.ofHex("1122334455667788"));
    var codec = new DdsCodec();

    switch (codec.write(texture)) {
      case Success(encoded):
        switch (codec.read(encoded)) {
          case Success(parsed):
            Assertions.assertEquals("dds width", 2, parsed.size.width);
            Assertions.assertEquals("dds format", PixelFormats.BGRA8_UNORM.id, parsed.format.id);
            Assertions.assertEquals("dds bytes", "1122334455667788", parsed.getPrimaryMipLevel().data.toHex());
          case Failure(error):
            Assertions.fail('Expected DDS BGRA round trip parse to succeed: ${error.toString()}');
        }
      case Failure(error):
        Assertions.fail('Expected DDS BGRA write to succeed: ${error.toString()}');
    }
  }

  static function testDdsCompressedRoundTrip():Void {
    var texture = new TextureData(digigun.formats.image.TextureDimension.Texture2D, new ImageSize(4, 4), PixelFormats.BC1_RGB_UNORM);
    var surface = texture.getOrCreatePrimarySurface();
    surface.setMipLevel(new MipLevel(0, new ImageSize(4, 4), ByteBuffer.wrap(Bytes.ofHex("1122334455667788"))));
    var codec = new DdsCodec();

    switch (codec.write(texture)) {
      case Success(encoded):
        switch (codec.read(encoded)) {
          case Success(parsed):
            Assertions.assertEquals("dds compressed format", PixelFormats.BC1_RGB_UNORM.id, parsed.format.id);
            Assertions.assertEquals("dds compressed bytes", "1122334455667788", parsed.getPrimaryMipLevel().data.toHex());
          case Failure(error):
            Assertions.fail('Expected DDS compressed round trip parse to succeed: ${error.toString()}');
        }
      case Failure(error):
        Assertions.fail('Expected DDS compressed write to succeed: ${error.toString()}');
    }
  }

  static function testDdsBc4RoundTrip():Void {
    var texture = new TextureData(digigun.formats.image.TextureDimension.Texture2D, new ImageSize(4, 4), PixelFormats.BC4_R_UNORM);
    var surface = texture.getOrCreatePrimarySurface();
    surface.setMipLevel(new MipLevel(0, new ImageSize(4, 4), ByteBuffer.wrap(Bytes.ofHex("fffe000000000000"))));
    var codec = new DdsCodec();

    switch (codec.write(texture)) {
      case Success(encoded):
        switch (codec.read(encoded)) {
          case Success(parsed):
            Assertions.assertEquals("dds bc4 format", PixelFormats.BC4_R_UNORM.id, parsed.format.id);
            Assertions.assertEquals("dds bc4 bytes", "fffe000000000000", parsed.getPrimaryMipLevel().data.toHex());
          case Failure(error):
            Assertions.fail('Expected DDS BC4 round trip parse to succeed: ${error.toString()}');
        }
      case Failure(error):
        Assertions.fail('Expected DDS BC4 write to succeed: ${error.toString()}');
    }
  }

  static function testDdsBc5RoundTrip():Void {
    var texture = new TextureData(digigun.formats.image.TextureDimension.Texture2D, new ImageSize(4, 4), PixelFormats.BC5_RG_UNORM);
    var surface = texture.getOrCreatePrimarySurface();
    surface.setMipLevel(new MipLevel(0, new ImageSize(4, 4), ByteBuffer.wrap(Bytes.ofHex("fffe000000000000fffe000000000000"))));
    var codec = new DdsCodec();

    switch (codec.write(texture)) {
      case Success(encoded):
        switch (codec.read(encoded)) {
          case Success(parsed):
            Assertions.assertEquals("dds bc5 format", PixelFormats.BC5_RG_UNORM.id, parsed.format.id);
            Assertions.assertEquals("dds bc5 bytes", "fffe000000000000fffe000000000000", parsed.getPrimaryMipLevel().data.toHex());
          case Failure(error):
            Assertions.fail('Expected DDS BC5 round trip parse to succeed: ${error.toString()}');
        }
      case Failure(error):
        Assertions.fail('Expected DDS BC5 write to succeed: ${error.toString()}');
    }
  }

  static function testDdsMipChainRoundTrip():Void {
    var texture = new TextureData(digigun.formats.image.TextureDimension.Texture2D, new ImageSize(4, 4), PixelFormats.BC1_RGB_UNORM);
    var surface = texture.getOrCreatePrimarySurface();
    surface.setMipLevel(new MipLevel(0, new ImageSize(4, 4), ByteBuffer.wrap(Bytes.ofHex("0011223344556677"))));
    surface.setMipLevel(new MipLevel(1, new ImageSize(2, 2), ByteBuffer.wrap(Bytes.ofHex("8899aabbccddeeff"))));
    var codec = new DdsCodec();

    switch (codec.write(texture)) {
      case Success(encoded):
        switch (codec.read(encoded)) {
          case Success(parsed):
            Assertions.assertEquals("dds mip count", 2, parsed.getPrimarySurface().mipLevels.length);
            Assertions.assertEquals("dds mip 1 bytes", "8899aabbccddeeff", parsed.getPrimarySurface().getMipLevel(1).data.toHex());
          case Failure(error):
            Assertions.fail('Expected DDS mip parse to succeed: ${error.toString()}');
        }
      case Failure(error):
        Assertions.fail('Expected DDS mip write to succeed: ${error.toString()}');
    }
  }

  static function testInvalidDds():Void {
    var codec = new DdsCodec();
    switch (codec.read(Bytes.ofHex("44445320"))) {
      case Failure(error):
        Assertions.assertEquals("invalid dds code", FormatErrorCode.InvalidInput, error.code);
      case Success(_):
        Assertions.fail("Expected invalid DDS bytes to fail.");
    }
  }

  static function testDdsUnsupportedFourCc():Void {
    var texture = new TextureData(digigun.formats.image.TextureDimension.Texture2D, new ImageSize(4, 4), PixelFormats.BC1_RGB_UNORM);
    var surface = texture.getOrCreatePrimarySurface();
    surface.setMipLevel(new MipLevel(0, new ImageSize(4, 4), ByteBuffer.wrap(Bytes.ofHex("1122334455667788"))));
    var codec = new DdsCodec();

    switch (codec.write(texture)) {
      case Success(encoded):
        var invalid = Bytes.alloc(encoded.length);
        invalid.blit(0, encoded, 0, encoded.length);
        invalid.set(84, 68);
        invalid.set(85, 88);
        invalid.set(86, 49);
        invalid.set(87, 48);
        switch (codec.read(invalid)) {
          case Failure(error):
            Assertions.assertEquals("dds unsupported fourcc code", FormatErrorCode.UnsupportedFeature, error.code);
          case Success(_):
            Assertions.fail("Expected unsupported DDS fourCC to fail.");
        }
      case Failure(error):
        Assertions.fail('Expected DDS compressed write to succeed: ${error.toString()}');
    }
  }
}
