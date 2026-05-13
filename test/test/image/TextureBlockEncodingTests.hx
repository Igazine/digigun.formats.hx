package test.image;

import digigun.formats.FormatErrorCode;
import digigun.formats.image.Astc4x4RgbaTextureBlockEncoder;
import digigun.formats.image.Bc1TextureBlockEncoder;
import digigun.formats.image.Bc4TextureBlockEncoder;
import digigun.formats.image.Bc3TextureBlockEncoder;
import digigun.formats.image.Bc5TextureBlockEncoder;
import digigun.formats.image.ByteBuffer;
import digigun.formats.image.EacR11TextureBlockEncoder;
import digigun.formats.image.EacRg11TextureBlockEncoder;
import digigun.formats.image.Etc2Rgb8TextureBlockEncoder;
import digigun.formats.image.Etc2Rgba8TextureBlockEncoder;
import digigun.formats.image.ImageSize;
import digigun.formats.image.MipLevel;
import digigun.formats.image.PixelFormats;
import digigun.formats.image.TextureBlockEncodingOptions;
import digigun.formats.image.TextureBlockEncodingSupport;
import digigun.formats.image.TextureCompressionMethod;
import digigun.formats.image.TextureData;
import digigun.formats.image.TextureDimension;
import digigun.formats.image.TextureEncodingRequest;
import digigun.formats.image.TextureContainerFormat;
import haxe.io.Bytes;
import test.Assertions;

class TextureBlockEncodingTests {
  public static function run():Void {
    testEncoderRegistry();
    testCompressedPassthrough();
    testRealBc1Encoding();
    testRealBc3Encoding();
    testRealBc4Encoding();
    testRealBc5Encoding();
    testRealEtc2Encoding();
    testRealEtc2RgbaEncoding();
    testRealEacR11Encoding();
    testRealEacRg11Encoding();
    testPlannedEncodeDispatch();
  }

  static function testEncoderRegistry():Void {
    var encoder = TextureBlockEncodingSupport.createEncoder(TextureCompressionMethod.BC1);
    Assertions.assertEquals("encoder method", TextureCompressionMethod.BC1, encoder.method);
    Assertions.assertEquals("encoder format", PixelFormats.BC1_RGB_UNORM.id, encoder.outputFormat.id);
    Assertions.assertTrue("astc encoder type", Std.isOfType(TextureBlockEncodingSupport.createEncoder(TextureCompressionMethod.Astc4x4Rgba), Astc4x4RgbaTextureBlockEncoder));
    Assertions.assertTrue("bc1 encoder type", Std.isOfType(encoder, Bc1TextureBlockEncoder));
    Assertions.assertTrue("bc3 encoder type", Std.isOfType(TextureBlockEncodingSupport.createEncoder(TextureCompressionMethod.BC3), Bc3TextureBlockEncoder));
    Assertions.assertTrue("bc4 encoder type", Std.isOfType(TextureBlockEncodingSupport.createEncoder(TextureCompressionMethod.BC4), Bc4TextureBlockEncoder));
    Assertions.assertTrue("bc5 encoder type", Std.isOfType(TextureBlockEncodingSupport.createEncoder(TextureCompressionMethod.BC5), Bc5TextureBlockEncoder));
    Assertions.assertTrue("etc2 encoder type", Std.isOfType(TextureBlockEncodingSupport.createEncoder(TextureCompressionMethod.ETC2Rgb8), Etc2Rgb8TextureBlockEncoder));
    Assertions.assertTrue("etc2 rgba encoder type", Std.isOfType(TextureBlockEncodingSupport.createEncoder(TextureCompressionMethod.ETC2Rgba8), Etc2Rgba8TextureBlockEncoder));
    Assertions.assertTrue("eac r11 encoder type", Std.isOfType(TextureBlockEncodingSupport.createEncoder(TextureCompressionMethod.EacR11), EacR11TextureBlockEncoder));
    Assertions.assertTrue("eac rg11 encoder type", Std.isOfType(TextureBlockEncodingSupport.createEncoder(TextureCompressionMethod.EacRg11), EacRg11TextureBlockEncoder));
  }

  static function testCompressedPassthrough():Void {
    var texture = new TextureData(TextureDimension.Texture2D, new ImageSize(4, 4), PixelFormats.BC1_RGB_UNORM);
    texture.getOrCreatePrimarySurface().setMipLevel(new MipLevel(0, new ImageSize(4, 4), ByteBuffer.wrap(Bytes.ofHex("0011223344556677"))));

    var encoder = TextureBlockEncodingSupport.createEncoder(TextureCompressionMethod.BC1);
    switch (encoder.encode(texture, new TextureBlockEncodingOptions())) {
      case Success(result):
        Assertions.assertTrue("passthrough flag", result.wasPassthrough);
        Assertions.assertEquals("passthrough texture format", PixelFormats.BC1_RGB_UNORM.id, result.texture.format.id);
      case Failure(error):
        Assertions.fail('Expected BC1 passthrough to succeed: ${error.toString()}');
    }
  }

  static function testRealBc1Encoding():Void {
    var source = Bytes.alloc(4 * 4 * 3);
    for (pixel in 0...16) {
      var offset = pixel * 3;
      source.set(offset, 0xff);
      source.set(offset + 1, 0x00);
      source.set(offset + 2, 0x00);
    }
    var texture = TextureData.fromBytes2D(new ImageSize(4, 4), PixelFormats.RGB8_UNORM, source);
    var encoder = TextureBlockEncodingSupport.createEncoder(TextureCompressionMethod.BC1);
    switch (encoder.encode(texture, new TextureBlockEncodingOptions())) {
      case Success(result):
        Assertions.assertTrue("bc1 real encode not passthrough", !result.wasPassthrough);
        Assertions.assertEquals("bc1 encoded format", PixelFormats.BC1_RGB_UNORM.id, result.texture.format.id);
        Assertions.assertEquals("bc1 encoded byte length", 8, result.texture.getPrimaryMipLevel().data.length);
        Assertions.assertEquals("bc1 encoded bytes", "01f800f855555555", result.texture.getPrimaryMipLevel().data.toHex());
      case Failure(error):
        Assertions.fail('Expected real BC1 encoding to succeed: ${error.toString()}');
    }
  }

  static function testRealBc3Encoding():Void {
    var source = Bytes.alloc(4 * 4 * 4);
    for (pixel in 0...16) {
      var offset = pixel * 4;
      source.set(offset, 0xff);
      source.set(offset + 1, 0x00);
      source.set(offset + 2, 0x00);
      source.set(offset + 3, 0xff);
    }
    var texture = TextureData.fromBytes2D(new ImageSize(4, 4), PixelFormats.RGBA8_UNORM, source);
    var encoder = TextureBlockEncodingSupport.createEncoder(TextureCompressionMethod.BC3);
    switch (encoder.encode(texture, new TextureBlockEncodingOptions())) {
      case Success(result):
        Assertions.assertTrue("bc3 real encode not passthrough", !result.wasPassthrough);
        Assertions.assertEquals("bc3 encoded format", PixelFormats.BC3_RGBA_UNORM.id, result.texture.format.id);
        Assertions.assertEquals("bc3 encoded byte length", 16, result.texture.getPrimaryMipLevel().data.length);
        Assertions.assertEquals("bc3 encoded bytes", "fffe00000000000001f800f855555555", result.texture.getPrimaryMipLevel().data.toHex());
      case Failure(error):
        Assertions.fail('Expected real BC3 encoding to succeed: ${error.toString()}');
    }
  }

  static function testRealBc4Encoding():Void {
    var source = Bytes.alloc(4 * 4);
    for (pixel in 0...16) {
      source.set(pixel, 0xff);
    }
    var texture = TextureData.fromBytes2D(new ImageSize(4, 4), PixelFormats.R8_UNORM, source);
    var encoder = TextureBlockEncodingSupport.createEncoder(TextureCompressionMethod.BC4);
    switch (encoder.encode(texture, new TextureBlockEncodingOptions())) {
      case Success(result):
        Assertions.assertTrue("bc4 real encode not passthrough", !result.wasPassthrough);
        Assertions.assertEquals("bc4 encoded format", PixelFormats.BC4_R_UNORM.id, result.texture.format.id);
        Assertions.assertEquals("bc4 encoded byte length", 8, result.texture.getPrimaryMipLevel().data.length);
        Assertions.assertEquals("bc4 encoded bytes", "fffe000000000000", result.texture.getPrimaryMipLevel().data.toHex());
      case Failure(error):
        Assertions.fail('Expected real BC4 encoding to succeed: ${error.toString()}');
    }
  }

  static function testRealBc5Encoding():Void {
    var source = Bytes.alloc(4 * 4 * 2);
    for (pixel in 0...16) {
      var offset = pixel * 2;
      source.set(offset, 0xff);
      source.set(offset + 1, 0xff);
    }
    var texture = TextureData.fromBytes2D(new ImageSize(4, 4), PixelFormats.RG8_UNORM, source);
    var encoder = TextureBlockEncodingSupport.createEncoder(TextureCompressionMethod.BC5);
    switch (encoder.encode(texture, new TextureBlockEncodingOptions())) {
      case Success(result):
        Assertions.assertTrue("bc5 real encode not passthrough", !result.wasPassthrough);
        Assertions.assertEquals("bc5 encoded format", PixelFormats.BC5_RG_UNORM.id, result.texture.format.id);
        Assertions.assertEquals("bc5 encoded byte length", 16, result.texture.getPrimaryMipLevel().data.length);
        Assertions.assertEquals("bc5 encoded bytes", "fffe000000000000fffe000000000000", result.texture.getPrimaryMipLevel().data.toHex());
      case Failure(error):
        Assertions.fail('Expected real BC5 encoding to succeed: ${error.toString()}');
    }
  }

  static function testRealEtc2Encoding():Void {
    var source = Bytes.alloc(4 * 4 * 3);
    for (pixel in 0...16) {
      var offset = pixel * 3;
      source.set(offset, 0x00);
      source.set(offset + 1, 0xff);
      source.set(offset + 2, 0x00);
    }
    var texture = TextureData.fromBytes2D(new ImageSize(4, 4), PixelFormats.RGB8_UNORM, source);
    var encoder = TextureBlockEncodingSupport.createEncoder(TextureCompressionMethod.ETC2Rgb8);
    switch (encoder.encode(texture, new TextureBlockEncodingOptions())) {
      case Success(result):
        Assertions.assertTrue("etc2 real encode not passthrough", !result.wasPassthrough);
        Assertions.assertEquals("etc2 encoded format", PixelFormats.ETC2_RGB8_UNORM.id, result.texture.format.id);
        Assertions.assertEquals("etc2 encoded byte length", 8, result.texture.getPrimaryMipLevel().data.length);
        Assertions.assertEquals("etc2 encoded bytes", "00ff0000ffff0000", result.texture.getPrimaryMipLevel().data.toHex());
      case Failure(error):
        Assertions.fail('Expected real ETC2 encoding to succeed: ${error.toString()}');
    }
  }

  static function testRealEtc2RgbaEncoding():Void {
    var source = Bytes.alloc(4 * 4 * 4);
    for (pixel in 0...16) {
      var offset = pixel * 4;
      source.set(offset, 0x00);
      source.set(offset + 1, 0xff);
      source.set(offset + 2, 0x00);
      source.set(offset + 3, 0xff);
    }
    var texture = TextureData.fromBytes2D(new ImageSize(4, 4), PixelFormats.RGBA8_UNORM, source);
    var encoder = TextureBlockEncodingSupport.createEncoder(TextureCompressionMethod.ETC2Rgba8);
    switch (encoder.encode(texture, new TextureBlockEncodingOptions())) {
      case Success(result):
        Assertions.assertTrue("etc2 rgba real encode not passthrough", !result.wasPassthrough);
        Assertions.assertEquals("etc2 rgba encoded format", PixelFormats.ETC2_RGBA8_UNORM.id, result.texture.format.id);
        Assertions.assertEquals("etc2 rgba encoded byte length", 16, result.texture.getPrimaryMipLevel().data.length);
      case Failure(error):
        Assertions.fail('Expected real ETC2 RGBA encoding to succeed: ${error.toString()}');
    }
  }

  static function testRealEacR11Encoding():Void {
    var source = Bytes.alloc(4 * 4);
    for (pixel in 0...16) {
      source.set(pixel, 0x80);
    }
    var texture = TextureData.fromBytes2D(new ImageSize(4, 4), PixelFormats.R8_UNORM, source);
    var encoder = TextureBlockEncodingSupport.createEncoder(TextureCompressionMethod.EacR11);
    switch (encoder.encode(texture, new TextureBlockEncodingOptions())) {
      case Success(result):
        Assertions.assertTrue("eac r11 real encode not passthrough", !result.wasPassthrough);
        Assertions.assertEquals("eac r11 encoded format", PixelFormats.EAC_R11_UNORM.id, result.texture.format.id);
        Assertions.assertEquals("eac r11 encoded byte length", 8, result.texture.getPrimaryMipLevel().data.length);
      case Failure(error):
        Assertions.fail('Expected real EAC R11 encoding to succeed: ${error.toString()}');
    }
  }

  static function testRealEacRg11Encoding():Void {
    var source = Bytes.alloc(4 * 4 * 2);
    for (pixel in 0...16) {
      var offset = pixel * 2;
      source.set(offset, 0x80);
      source.set(offset + 1, 0x40);
    }
    var texture = TextureData.fromBytes2D(new ImageSize(4, 4), PixelFormats.RG8_UNORM, source);
    var encoder = TextureBlockEncodingSupport.createEncoder(TextureCompressionMethod.EacRg11);
    switch (encoder.encode(texture, new TextureBlockEncodingOptions())) {
      case Success(result):
        Assertions.assertTrue("eac rg11 real encode not passthrough", !result.wasPassthrough);
        Assertions.assertEquals("eac rg11 encoded format", PixelFormats.EAC_RG11_UNORM.id, result.texture.format.id);
        Assertions.assertEquals("eac rg11 encoded byte length", 16, result.texture.getPrimaryMipLevel().data.length);
      case Failure(error):
        Assertions.fail('Expected real EAC RG11 encoding to succeed: ${error.toString()}');
    }
  }

  static function testPlannedEncodeDispatch():Void {
    var compressedTexture = TextureData.fromBytes2D(new ImageSize(4, 4), PixelFormats.BC3_RGBA_UNORM, Bytes.ofHex("00112233445566778899aabbccddeeff"));
    var compressedRequest = new TextureEncodingRequest(digigun.formats.image.GraphicsApi.Direct3D11, compressedTexture, true, false, false, TextureContainerFormat.Dds);

    switch (TextureBlockEncodingSupport.encode(compressedRequest, new TextureBlockEncodingOptions())) {
      case Success(result):
        Assertions.assertEquals("planned dispatch method", TextureCompressionMethod.BC3, result.method);
        Assertions.assertTrue("planned dispatch passthrough", result.wasPassthrough);
      case Failure(error):
        Assertions.fail('Expected planned BC3 dispatch to succeed: ${error.toString()}');
    }

    var rgbTexture = TextureData.fromBytes2D(new ImageSize(4, 4), PixelFormats.RGB8_UNORM, Bytes.alloc(48));
    var rgbRequest = new TextureEncodingRequest(digigun.formats.image.GraphicsApi.Direct3D11, rgbTexture, false, false, false, TextureContainerFormat.Dds);
    switch (TextureBlockEncodingSupport.encode(rgbRequest, new TextureBlockEncodingOptions())) {
      case Success(result):
        Assertions.assertEquals("planned bc1 dispatch method", TextureCompressionMethod.BC1, result.method);
        Assertions.assertEquals("planned bc1 dispatch format", PixelFormats.BC1_RGB_UNORM.id, result.texture.format.id);
      case Failure(error):
        Assertions.fail('Expected planned BC1 dispatch to succeed: ${error.toString()}');
    }

    var rTexture = TextureData.fromBytes2D(new ImageSize(4, 4), PixelFormats.R8_UNORM, Bytes.alloc(16));
    var rRequest = new TextureEncodingRequest(digigun.formats.image.GraphicsApi.Direct3D11, rTexture, false, false, false, TextureContainerFormat.Dds);
    switch (TextureBlockEncodingSupport.encode(rRequest, new TextureBlockEncodingOptions())) {
      case Success(result):
        Assertions.assertEquals("planned bc4 dispatch method", TextureCompressionMethod.BC4, result.method);
        Assertions.assertEquals("planned bc4 dispatch format", PixelFormats.BC4_R_UNORM.id, result.texture.format.id);
      case Failure(error):
        Assertions.fail('Expected planned BC4 encode dispatch to succeed: ${error.toString()}');
    }

    var rgTexture = TextureData.fromBytes2D(new ImageSize(4, 4), PixelFormats.RG8_UNORM, Bytes.alloc(32));
    var rgRequest = new TextureEncodingRequest(digigun.formats.image.GraphicsApi.Direct3D11, rgTexture, false, false, false, TextureContainerFormat.Dds);
    switch (TextureBlockEncodingSupport.encode(rgRequest, new TextureBlockEncodingOptions())) {
      case Success(result):
        Assertions.assertEquals("planned bc5 dispatch method", TextureCompressionMethod.BC5, result.method);
        Assertions.assertEquals("planned bc5 dispatch format", PixelFormats.BC5_RG_UNORM.id, result.texture.format.id);
      case Failure(error):
        Assertions.fail('Expected planned BC5 encode dispatch to succeed: ${error.toString()}');
    }

    var rgbaTexture = TextureData.fromBytes2D(new ImageSize(4, 4), PixelFormats.RGBA8_UNORM, Bytes.alloc(64));
    var rgbaRequest = new TextureEncodingRequest(digigun.formats.image.GraphicsApi.Direct3D11, rgbaTexture, true, false, false, TextureContainerFormat.Dds);
    switch (TextureBlockEncodingSupport.encode(rgbaRequest, new TextureBlockEncodingOptions())) {
      case Success(result):
        Assertions.assertEquals("planned bc3 dispatch method", TextureCompressionMethod.BC3, result.method);
        Assertions.assertEquals("planned bc3 dispatch format", PixelFormats.BC3_RGBA_UNORM.id, result.texture.format.id);
      case Failure(error):
        Assertions.fail('Expected planned BC3 encode dispatch to succeed: ${error.toString()}');
    }

    var webRgbTexture = TextureData.fromBytes2D(new ImageSize(4, 4), PixelFormats.RGB8_UNORM, Bytes.alloc(48));
    var webRgbRequest = new TextureEncodingRequest(digigun.formats.image.GraphicsApi.WebGL, webRgbTexture, false, false, false, TextureContainerFormat.Ktx);
    switch (TextureBlockEncodingSupport.encode(webRgbRequest, new TextureBlockEncodingOptions())) {
      case Success(result):
        Assertions.assertEquals("planned etc2 dispatch method", TextureCompressionMethod.ETC2Rgb8, result.method);
        Assertions.assertEquals("planned etc2 dispatch format", PixelFormats.ETC2_RGB8_UNORM.id, result.texture.format.id);
      case Failure(error):
        Assertions.fail('Expected planned ETC2 encode dispatch to succeed: ${error.toString()}');
    }

    var webAlphaTexture = TextureData.fromBytes2D(new ImageSize(4, 4), PixelFormats.RGBA8_UNORM, Bytes.alloc(64));
    var webAlphaRequest = new TextureEncodingRequest(digigun.formats.image.GraphicsApi.WebGL, webAlphaTexture, true, false, false, TextureContainerFormat.Ktx);
    switch (TextureBlockEncodingSupport.encode(webAlphaRequest, new TextureBlockEncodingOptions())) {
      case Success(result):
        Assertions.assertEquals("planned etc2 rgba dispatch method", TextureCompressionMethod.ETC2Rgba8, result.method);
        Assertions.assertEquals("planned etc2 rgba dispatch format", PixelFormats.ETC2_RGBA8_UNORM.id, result.texture.format.id);
      case Failure(error):
        Assertions.fail('Expected planned ETC2 RGBA encode dispatch to succeed: ${error.toString()}');
    }

    var webRTexture = TextureData.fromBytes2D(new ImageSize(4, 4), PixelFormats.R8_UNORM, Bytes.alloc(16));
    var webRRequest = new TextureEncodingRequest(digigun.formats.image.GraphicsApi.WebGL, webRTexture, false, false, false, TextureContainerFormat.Ktx);
    switch (TextureBlockEncodingSupport.encode(webRRequest, new TextureBlockEncodingOptions())) {
      case Success(result):
        Assertions.assertEquals("planned eac r11 dispatch method", TextureCompressionMethod.EacR11, result.method);
        Assertions.assertEquals("planned eac r11 dispatch format", PixelFormats.EAC_R11_UNORM.id, result.texture.format.id);
      case Failure(error):
        Assertions.fail('Expected planned EAC R11 encode dispatch to succeed: ${error.toString()}');
    }

    var webRgTexture = TextureData.fromBytes2D(new ImageSize(4, 4), PixelFormats.RG8_UNORM, Bytes.alloc(32));
    var webRgRequest = new TextureEncodingRequest(digigun.formats.image.GraphicsApi.WebGL, webRgTexture, false, false, false, TextureContainerFormat.Ktx);
    switch (TextureBlockEncodingSupport.encode(webRgRequest, new TextureBlockEncodingOptions())) {
      case Success(result):
        Assertions.assertEquals("planned eac rg11 dispatch method", TextureCompressionMethod.EacRg11, result.method);
        Assertions.assertEquals("planned eac rg11 dispatch format", PixelFormats.EAC_RG11_UNORM.id, result.texture.format.id);
      case Failure(error):
        Assertions.fail('Expected planned EAC RG11 encode dispatch to succeed: ${error.toString()}');
    }
  }
}
