package digigun.formats.image.raw;

import digigun.formats.image.ImageSize;
import digigun.formats.image.PixelFormat;

/**
 * Declares the layout required to interpret or write headerless bitmap data.
 */
class RawImageSpec {
  /** Dimensions of the raw bitmap data. */
  public var size(default, null):ImageSize;

  /** Pixel or block-compressed layout carried by the raw bytes. */
  public var format(default, null):PixelFormat;

  /**
   * Creates a new RAW image specification.
   */
  public function new(size:ImageSize, format:PixelFormat) {
    this.size = size;
    this.format = format;
  }

  /**
   * Returns the byte count required for this specification.
   */
  public function expectedByteLength():Int {
    return format.byteLengthFor(size);
  }
}
