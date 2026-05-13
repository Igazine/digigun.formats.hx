package test.image;

import digigun.formats.FormatErrorCode;
import digigun.formats.image.ByteBuffer;
import digigun.formats.image.ImageSize;
import digigun.formats.image.MipLevel;
import digigun.formats.image.PixelFormats;
import digigun.formats.image.TextureData;
import digigun.formats.image.TextureDimension;
import digigun.formats.image.pvr.PvrCodec;
import haxe.io.Bytes;
import test.Assertions;

class PvrTests {
  public static function run():Void {
    testPvrRoundTrip();
    testPvrUnsupportedSurfaceCount();
    testInvalidPvr();
  }

  static function testPvrRoundTrip():Void {
    var texture = new TextureData(TextureDimension.Texture2D, new ImageSize(4, 4), PixelFormats.PVRTC1_4_RGBA_UNORM);
    texture.getOrCreatePrimarySurface().setMipLevel(new MipLevel(0, new ImageSize(4, 4), ByteBuffer.wrap(Bytes.ofHex("1122334455667788"))));
    var codec = new PvrCodec();
    switch (codec.write(texture)) {
      case Success(encoded):
        switch (codec.read(encoded)) {
          case Success(parsed):
            Assertions.assertEquals("pvr format", PixelFormats.PVRTC1_4_RGBA_UNORM.id, parsed.format.id);
            Assertions.assertEquals("pvr bytes", "1122334455667788", parsed.getPrimaryMipLevel().data.toHex());
          case Failure(error):
            Assertions.fail('Expected PVR parse to succeed: ${error.toString()}');
        }
      case Failure(error):
        Assertions.fail('Expected PVR write to succeed: ${error.toString()}');
    }
  }

  static function testInvalidPvr():Void {
    var codec = new PvrCodec();
    switch (codec.read(Bytes.ofHex("50565203"))) {
      case Failure(error):
        Assertions.assertEquals("invalid pvr code", FormatErrorCode.InvalidInput, error.code);
      case Success(_):
        Assertions.fail("Expected invalid PVR bytes to fail.");
    }
  }

  static function testPvrUnsupportedSurfaceCount():Void {
    var texture = new TextureData(TextureDimension.Texture2D, new ImageSize(4, 4), PixelFormats.PVRTC1_4_RGBA_UNORM);
    texture.getOrCreatePrimarySurface().setMipLevel(new MipLevel(0, new ImageSize(4, 4), ByteBuffer.wrap(Bytes.ofHex("1122334455667788"))));
    var codec = new PvrCodec();

    switch (codec.write(texture)) {
      case Success(encoded):
        var invalid = Bytes.alloc(encoded.length);
        invalid.blit(0, encoded, 0, encoded.length);
        invalid.set(36, 2);
        switch (codec.read(invalid)) {
          case Failure(error):
            Assertions.assertEquals("pvr unsupported surface count code", FormatErrorCode.UnsupportedFeature, error.code);
          case Success(_):
            Assertions.fail("Expected multi-surface PVR bytes to fail.");
        }
      case Failure(error):
        Assertions.fail('Expected PVR write to succeed: ${error.toString()}');
    }
  }
}
