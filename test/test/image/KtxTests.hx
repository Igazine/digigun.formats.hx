package test.image;

import digigun.formats.FormatErrorCode;
import digigun.formats.image.ByteBuffer;
import digigun.formats.image.ImageSize;
import digigun.formats.image.MipLevel;
import digigun.formats.image.PixelFormats;
import digigun.formats.image.TextureData;
import digigun.formats.image.TextureDimension;
import digigun.formats.image.ktx.KtxCodec;
import haxe.io.Bytes;
import test.Assertions;

class KtxTests {
  public static function run():Void {
    testKtxRgbaRoundTrip();
    testKtxCompressedRoundTrip();
    testKtxMipChainRoundTrip();
    testInvalidKtx();
  }

  static function testKtxRgbaRoundTrip():Void {
    var texture = TextureData.fromBytes2D(new ImageSize(1, 1), PixelFormats.RGBA8_UNORM, Bytes.ofHex("11223344"));
    var codec = new KtxCodec();
    switch (codec.write(texture)) {
      case Success(encoded):
        switch (codec.read(encoded)) {
          case Success(parsed):
            Assertions.assertEquals("ktx rgba format", PixelFormats.RGBA8_UNORM.id, parsed.format.id);
            Assertions.assertEquals("ktx rgba bytes", "11223344", parsed.getPrimaryMipLevel().data.toHex());
          case Failure(error):
            Assertions.fail('Expected KTX RGBA parse to succeed: ${error.toString()}');
        }
      case Failure(error):
        Assertions.fail('Expected KTX RGBA write to succeed: ${error.toString()}');
    }
  }

  static function testKtxCompressedRoundTrip():Void {
    var texture = new TextureData(TextureDimension.Texture2D, new ImageSize(4, 4), PixelFormats.BC3_RGBA_UNORM);
    texture.getOrCreatePrimarySurface().setMipLevel(new MipLevel(0, new ImageSize(4, 4), ByteBuffer.wrap(Bytes.ofHex("00112233445566778899aabbccddeeff"))));
    var codec = new KtxCodec();
    switch (codec.write(texture)) {
      case Success(encoded):
        switch (codec.read(encoded)) {
          case Success(parsed):
            Assertions.assertEquals("ktx compressed format", PixelFormats.BC3_RGBA_UNORM.id, parsed.format.id);
            Assertions.assertEquals("ktx compressed bytes", "00112233445566778899aabbccddeeff", parsed.getPrimaryMipLevel().data.toHex());
          case Failure(error):
            Assertions.fail('Expected KTX compressed parse to succeed: ${error.toString()}');
        }
      case Failure(error):
        Assertions.fail('Expected KTX compressed write to succeed: ${error.toString()}');
    }
  }

  static function testKtxMipChainRoundTrip():Void {
    var texture = new TextureData(TextureDimension.Texture2D, new ImageSize(4, 4), PixelFormats.BC1_RGB_UNORM);
    var surface = texture.getOrCreatePrimarySurface();
    surface.setMipLevel(new MipLevel(0, new ImageSize(4, 4), ByteBuffer.wrap(Bytes.ofHex("1122334455667788"))));
    surface.setMipLevel(new MipLevel(1, new ImageSize(2, 2), ByteBuffer.wrap(Bytes.ofHex("99aabbccddeeff00"))));
    var codec = new KtxCodec();

    switch (codec.write(texture)) {
      case Success(encoded):
        switch (codec.read(encoded)) {
          case Success(parsed):
            Assertions.assertEquals("ktx mip count", 2, parsed.getPrimarySurface().mipLevels.length);
            Assertions.assertEquals("ktx mip 1 bytes", "99aabbccddeeff00", parsed.getPrimarySurface().getMipLevel(1).data.toHex());
          case Failure(error):
            Assertions.fail('Expected KTX mip parse to succeed: ${error.toString()}');
        }
      case Failure(error):
        Assertions.fail('Expected KTX mip write to succeed: ${error.toString()}');
    }
  }

  static function testInvalidKtx():Void {
    var codec = new KtxCodec();
    switch (codec.read(Bytes.ofHex("00010203"))) {
      case Failure(error):
        Assertions.assertEquals("invalid ktx code", FormatErrorCode.InvalidInput, error.code);
      case Success(_):
        Assertions.fail("Expected invalid KTX bytes to fail.");
    }
  }
}
