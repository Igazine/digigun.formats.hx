package digigun.formats.image;

/**
 * Stores one mip level for a texture surface.
 */
class MipLevel {
  /** Zero-based mip level index. */
  public var level(default, null):Int;

  /** Dimensions of this mip level. */
  public var size(default, null):ImageSize;

  /** Raw byte data for this level. */
  public var data(default, null):ByteBuffer;

  /**
   * Creates a new mip level descriptor.
   */
  public function new(level:Int, size:ImageSize, data:ByteBuffer) {
    if (level < 0) {
      throw 'Mip level must be non-negative: ${level}';
    }

    this.level = level;
    this.size = size;
    this.data = data;
  }

  /**
   * Creates a mip level from detached bytes.
   */
  public static function fromBytes(level:Int, size:ImageSize, data:haxe.io.Bytes):MipLevel {
    return new MipLevel(level, size, ByteBuffer.wrap(data));
  }
}
