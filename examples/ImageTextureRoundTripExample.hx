import digigun.formats.image.GraphicsApi;
import digigun.formats.image.ImageSize;
import digigun.formats.image.PixelFormats;
import digigun.formats.image.TextureCompressionSupport;
import digigun.formats.image.TextureData;
import digigun.formats.image.TextureFormatSupport;
import digigun.formats.image.tga.TgaCodec;
import haxe.io.Bytes;

class ImageTextureRoundTripExample {
  static function main() {
    var texture = TextureData.fromBytes2D(new ImageSize(2, 1), PixelFormats.R8_UNORM, Bytes.ofHex("7f7f"));
    var codec = new TgaCodec();

    trace("webgl supports ETC2: " + TextureFormatSupport.canUpload(GraphicsApi.WebGL, PixelFormats.ETC2_RGB8_UNORM));
    trace("metal preferred container: " + TextureCompressionSupport.recommendCompression(GraphicsApi.Metal).container);

    switch (codec.write(texture)) {
      case Success(bytes):
        switch (codec.read(bytes)) {
          case Success(parsed):
            trace(parsed.size.width + "x" + parsed.size.height + " " + parsed.format.id + " " + parsed.getPrimaryMipLevel().data.toHex());
          case Failure(error):
            trace(error.toString());
        }
      case Failure(error):
        trace(error.toString());
    }
  }
}
