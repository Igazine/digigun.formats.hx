package digigun.formats.image;

/**
 * Describes the dimensions of an image or texture region.
 */
class ImageSize {
  /** Width in pixels or blocks depending on the context. */
  public var width(default, null):Int;

  /** Height in pixels or blocks depending on the context. */
  public var height(default, null):Int;

  /** Depth in pixels, defaulting to 1 for 2D textures. */
  public var depth(default, null):Int;

  /**
   * Creates a new image size descriptor.
   */
  public function new(width:Int, height:Int, depth:Int = 1) {
    if (width <= 0 || height <= 0 || depth <= 0) {
      throw "ImageSize dimensions must be positive.";
    }

    this.width = width;
    this.height = height;
    this.depth = depth;
  }

  /**
   * Returns the number of texels in this size.
   */
  public function pixelCount():Int {
    return width * height * depth;
  }

  /**
   * Returns the size of a mip level derived from this size.
   */
  public function atMipLevel(level:Int):ImageSize {
    if (level < 0) {
      throw 'Mip level must be non-negative: ${level}';
    }

    var mipWidth = width;
    var mipHeight = height;
    var mipDepth = depth;

    for (_ in 0...level) {
      mipWidth = Std.int(Math.max(1, mipWidth >> 1));
      mipHeight = Std.int(Math.max(1, mipHeight >> 1));
      mipDepth = Std.int(Math.max(1, mipDepth >> 1));
    }

    return new ImageSize(mipWidth, mipHeight, mipDepth);
  }
}
