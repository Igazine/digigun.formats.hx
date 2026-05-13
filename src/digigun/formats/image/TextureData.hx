package digigun.formats.image;

/**
 * High-level container for texture data that can back image/texture formats.
 */
class TextureData {
  /** Texture dimension and topology. */
  public var dimension(default, null):TextureDimension;

  /** Base level size for the texture. */
  public var size(default, null):ImageSize;

  /** Pixel or compressed block format. */
  public var format(default, null):PixelFormat;

  /** Texture surfaces, typically one for a 2D image. */
  public var surfaces(default, null):Array<TextureSurface>;

  /**
   * Creates a new texture-data container.
   */
  public function new(dimension:TextureDimension, size:ImageSize, format:PixelFormat, ?surfaces:Array<TextureSurface>) {
    this.dimension = dimension;
    this.size = size;
    this.format = format;
    this.surfaces = surfaces == null ? [] : surfaces;
  }

  /**
   * Creates a 2D texture with a single surface and mip level from a byte buffer.
   */
  public static function fromBuffer2D(size:ImageSize, format:PixelFormat, data:ByteBuffer):TextureData {
    var texture = new TextureData(TextureDimension.Texture2D, size, format);
    texture.setPrimaryMipLevel(new MipLevel(0, size, data));
    return texture;
  }

  /**
   * Creates a 2D texture with a single surface and mip level from detached bytes.
   */
  public static function fromBytes2D(size:ImageSize, format:PixelFormat, data:haxe.io.Bytes):TextureData {
    return fromBuffer2D(size, format, ByteBuffer.wrap(data));
  }

  /**
   * Returns the surface for the given layer and face, or null when absent.
   */
  public function getSurface(layer:Int = 0, face:Int = 0):Null<TextureSurface> {
    for (surface in surfaces) {
      if (surface.layer == layer && surface.face == face) {
        return surface;
      }
    }

    return null;
  }

  /**
   * Returns an existing surface or creates a new one.
   */
  public function getOrCreateSurface(layer:Int = 0, face:Int = 0):TextureSurface {
    var surface = getSurface(layer, face);
    if (surface != null) {
      return surface;
    }

    surface = new TextureSurface(layer, face);
    surfaces.push(surface);
    return surface;
  }

  /**
   * Returns the primary surface for simple 2D images, or null when absent.
   */
  public function getPrimarySurface():Null<TextureSurface> {
    return getSurface(0, 0);
  }

  /**
   * Returns an existing primary surface or creates one.
   */
  public function getOrCreatePrimarySurface():TextureSurface {
    return getOrCreateSurface(0, 0);
  }

  /**
   * Returns mip level zero on the primary surface, or null when absent.
   */
  public function getPrimaryMipLevel():Null<MipLevel> {
    var surface = getPrimarySurface();
    return surface == null ? null : surface.getMipLevel(0);
  }

  /**
   * Sets mip level zero on the primary surface.
   */
  public function setPrimaryMipLevel(value:MipLevel):Void {
    getOrCreatePrimarySurface().setMipLevel(value);
  }

  /**
   * Returns the total byte length across every surface and mip level.
   */
  public function totalByteLength():Int {
    var total = 0;
    for (surface in surfaces) {
      total += surface.totalByteLength();
    }
    return total;
  }
}
