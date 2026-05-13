package test.image;

import digigun.formats.image.ByteBuffer;
import digigun.formats.image.ChannelOrder;
import digigun.formats.image.ChannelType;
import digigun.formats.image.ImageSize;
import digigun.formats.image.MipLevel;
import digigun.formats.image.PixelFormats;
import digigun.formats.image.TextureData;
import digigun.formats.image.TextureDimension;
import haxe.io.Bytes;
import test.Assertions;

class ImageTests {
  public static function run():Void {
    testByteBufferView();
    testImageSizeMipComputation();
    testUncompressedPixelFormats();
    testCompressedPixelFormats();
    testTextureDataEditing();
  }

  static function testByteBufferView():Void {
    var buffer = ByteBuffer.wrap(Bytes.ofHex("001122334455"));
    var slice = buffer.slice(2, 3);

    Assertions.assertEquals("byte buffer slice length", 3, slice.length);
    Assertions.assertEquals("byte buffer slice value", 0x22, slice.get(0));
    slice.set(1, 0xaa);
    Assertions.assertEquals("byte buffer shared storage", "001122aa4455", buffer.toHex());
  }

  static function testImageSizeMipComputation():Void {
    var size = new ImageSize(16, 8);
    var mip = size.atMipLevel(2);

    Assertions.assertEquals("image size mip width", 4, mip.width);
    Assertions.assertEquals("image size mip height", 2, mip.height);
    Assertions.assertEquals("image size pixel count", 128, size.pixelCount());
  }

  static function testUncompressedPixelFormats():Void {
    Assertions.assertEquals("channel order count", 4, ChannelOrder.RGBA.channelCount());
    Assertions.assertEquals("channel type byte size", 2, ChannelType.Float16.bytesPerChannel());
    Assertions.assertEquals("rgba8 bytes per pixel", 4, PixelFormats.RGBA8_UNORM.bytesPerPixel());
    Assertions.assertEquals("rgba16f bytes for 2x2", 32, PixelFormats.RGBA16_FLOAT.byteLengthFor(new ImageSize(2, 2)));
  }

  static function testCompressedPixelFormats():Void {
    Assertions.assertTrue("bc1 is compressed", PixelFormats.BC1_RGB_UNORM.isCompressed());
    Assertions.assertEquals("bc1 block byte size", 8, PixelFormats.BC1_RGB_UNORM.blockBytes);
    Assertions.assertEquals("bc1 8x8 byte size", 32, PixelFormats.BC1_RGB_UNORM.byteLengthFor(new ImageSize(8, 8)));
    Assertions.assertEquals("astc lookup", PixelFormats.ASTC_4X4_RGBA_UNORM.id, PixelFormats.byId("astc-4x4-rgba-unorm").id);
  }

  static function testTextureDataEditing():Void {
    var texture = new TextureData(TextureDimension.Texture2D, new ImageSize(4, 4), PixelFormats.RGBA8_UNORM);
    var surface = texture.getOrCreateSurface();
    surface.setMipLevel(new MipLevel(0, new ImageSize(4, 4), ByteBuffer.wrap(Bytes.alloc(64))));
    surface.setMipLevel(new MipLevel(1, new ImageSize(2, 2), ByteBuffer.wrap(Bytes.alloc(16))));

    Assertions.assertEquals("texture surface count", 1, texture.surfaces.length);
    Assertions.assertEquals("texture mip count", 2, surface.mipLevels.length);
    Assertions.assertEquals("texture total byte length", 80, texture.totalByteLength());
    Assertions.assertEquals("texture mip lookup", 2, surface.getMipLevel(1).size.width);
  }
}
