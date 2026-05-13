package test.image;

import digigun.formats.image.GraphicsApi;
import digigun.formats.image.PixelFormats;
import digigun.formats.image.TextureCompressionMethod;
import digigun.formats.image.TextureCompressionSupport;
import digigun.formats.image.TextureContainerFormat;
import digigun.formats.image.TextureData;
import digigun.formats.image.TextureEncodingRequest;
import digigun.formats.image.TextureFormatSupport;
import digigun.formats.image.TextureDimension;
import digigun.formats.image.ImageSize;
import haxe.io.Bytes;
import test.Assertions;

class TextureSupportTests {
  public static function run():Void {
    testApiUploadSupport();
    testCompressionRecommendations();
    testCompressionMetadata();
    testTranscodePlanning();
  }

  static function testApiUploadSupport():Void {
    Assertions.assertTrue("metal supports astc", TextureFormatSupport.canUpload(GraphicsApi.Metal, PixelFormats.ASTC_4X4_RGBA_UNORM));
    Assertions.assertTrue("d3d supports bc3", TextureFormatSupport.canUpload(GraphicsApi.Direct3D11, PixelFormats.BC3_RGBA_UNORM));
    Assertions.assertTrue("d3d supports bc4", TextureFormatSupport.canUpload(GraphicsApi.Direct3D11, PixelFormats.BC4_R_UNORM));
    Assertions.assertTrue("vulkan supports bc5", TextureFormatSupport.canUpload(GraphicsApi.Vulkan, PixelFormats.BC5_RG_UNORM));
    Assertions.assertTrue("webgl supports etc2", TextureFormatSupport.canUpload(GraphicsApi.WebGL, PixelFormats.ETC2_RGB8_UNORM));
    Assertions.assertTrue("webgl rejects pvrtc baseline helper", !TextureFormatSupport.canUpload(GraphicsApi.WebGL, PixelFormats.PVRTC1_4_RGBA_UNORM));
  }

  static function testCompressionRecommendations():Void {
    var metalPlan = TextureFormatSupport.recommendCompression(GraphicsApi.Metal);
    Assertions.assertEquals("metal compression format", PixelFormats.ASTC_4X4_RGBA_UNORM.id, metalPlan.format.id);
    Assertions.assertEquals("metal compression container", TextureContainerFormat.Ktx, metalPlan.container);

    var d3dPlan = TextureFormatSupport.recommendCompression(GraphicsApi.Direct3D11);
    Assertions.assertEquals("d3d compression format", PixelFormats.BC3_RGBA_UNORM.id, d3dPlan.format.id);
    Assertions.assertEquals("d3d compression container", TextureContainerFormat.Dds, d3dPlan.container);
  }

  static function testCompressionMetadata():Void {
    var info = TextureCompressionSupport.infoForFormat(PixelFormats.ASTC_4X4_RGBA_UNORM);
    Assertions.assertEquals("astc method", TextureCompressionMethod.Astc4x4Rgba, info.method);
    Assertions.assertEquals("astc block bytes", 16, info.blockBytes);
    Assertions.assertEquals("bc4 method", TextureCompressionMethod.BC4, TextureCompressionSupport.infoForFormat(PixelFormats.BC4_R_UNORM).method);
    Assertions.assertEquals("bc5 method", TextureCompressionMethod.BC5, TextureCompressionSupport.infoForFormat(PixelFormats.BC5_RG_UNORM).method);

    var profile = TextureCompressionSupport.containerProfile(TextureContainerFormat.Ktx);
    Assertions.assertTrue("ktx supports astc", profile.supportedFormatIds.indexOf(PixelFormats.ASTC_4X4_RGBA_UNORM.id) >= 0);
    Assertions.assertTrue("ktx supports bc4", profile.supportedFormatIds.indexOf(PixelFormats.BC4_R_UNORM.id) >= 0);
    Assertions.assertTrue("ktx supports bc5", profile.supportedFormatIds.indexOf(PixelFormats.BC5_RG_UNORM.id) >= 0);
    Assertions.assertTrue("dds supports bc4", TextureCompressionSupport.containerProfile(TextureContainerFormat.Dds).supportedFormatIds.indexOf(PixelFormats.BC4_R_UNORM.id) >= 0);
    Assertions.assertTrue("dds supports bc5", TextureCompressionSupport.containerProfile(TextureContainerFormat.Dds).supportedFormatIds.indexOf(PixelFormats.BC5_RG_UNORM.id) >= 0);
    Assertions.assertTrue("dds rejects astc baseline profile", TextureCompressionSupport.containerProfile(TextureContainerFormat.Dds).supportedFormatIds.indexOf(PixelFormats.ASTC_4X4_RGBA_UNORM.id) < 0);
  }

  static function testTranscodePlanning():Void {
    var rgbaTexture = TextureData.fromBytes2D(new ImageSize(4, 4), PixelFormats.RGBA8_UNORM, Bytes.alloc(64));
    var metalPlan = TextureCompressionSupport.buildPlan(new TextureEncodingRequest(GraphicsApi.Metal, rgbaTexture));
    Assertions.assertEquals("metal transcode format", PixelFormats.ASTC_4X4_RGBA_UNORM.id, metalPlan.outputFormat.id);
    Assertions.assertEquals("metal transcode container", TextureContainerFormat.Ktx, metalPlan.container);
    Assertions.assertTrue("metal requires gpu encoder", metalPlan.requiresGpuEncoder);

    var rgbTexture = new TextureData(TextureDimension.Texture2D, new ImageSize(4, 4), PixelFormats.RGB8_UNORM);
    var fallbackPlan = TextureCompressionSupport.buildPlan(new TextureEncodingRequest(GraphicsApi.Metal, rgbTexture, false, false, true, TextureContainerFormat.Pvr));
    Assertions.assertEquals("pvr preferred container chooses pvrtc", PixelFormats.PVRTC1_4_RGBA_UNORM.id, fallbackPlan.outputFormat.id);
    Assertions.assertEquals("pvr preferred container", TextureContainerFormat.Pvr, fallbackPlan.container);

    var d3dRgbPlan = TextureCompressionSupport.buildPlan(new TextureEncodingRequest(GraphicsApi.Direct3D11, rgbTexture, false));
    Assertions.assertEquals("d3d rgb plan prefers bc1", PixelFormats.BC1_RGB_UNORM.id, d3dRgbPlan.outputFormat.id);
    Assertions.assertEquals("d3d rgb method", TextureCompressionMethod.BC1, d3dRgbPlan.compressionMethod);

    var rTexture = TextureData.fromBytes2D(new ImageSize(4, 4), PixelFormats.R8_UNORM, Bytes.alloc(16));
    var d3dRPlan = TextureCompressionSupport.buildPlan(new TextureEncodingRequest(GraphicsApi.Direct3D11, rTexture, false, false, false, TextureContainerFormat.Dds));
    Assertions.assertEquals("d3d r plan prefers bc4", PixelFormats.BC4_R_UNORM.id, d3dRPlan.outputFormat.id);
    Assertions.assertEquals("d3d r method", TextureCompressionMethod.BC4, d3dRPlan.compressionMethod);

    var rgTexture = TextureData.fromBytes2D(new ImageSize(4, 4), PixelFormats.RG8_UNORM, Bytes.alloc(32));
    var d3dRgPlan = TextureCompressionSupport.buildPlan(new TextureEncodingRequest(GraphicsApi.Direct3D11, rgTexture, false, false, false, TextureContainerFormat.Dds));
    Assertions.assertEquals("d3d rg plan prefers bc5", PixelFormats.BC5_RG_UNORM.id, d3dRgPlan.outputFormat.id);
    Assertions.assertEquals("d3d rg method", TextureCompressionMethod.BC5, d3dRgPlan.compressionMethod);

    var forcedCompressedPlan = TextureCompressionSupport.buildPlan(new TextureEncodingRequest(GraphicsApi.WebGL, rgbTexture, false, false, false, TextureContainerFormat.Pvr));
    Assertions.assertEquals("forced compressed falls back to api container", TextureContainerFormat.Ktx, forcedCompressedPlan.container);
    Assertions.assertEquals("forced compressed format", PixelFormats.ETC2_RGB8_UNORM.id, forcedCompressedPlan.outputFormat.id);
  }
}
