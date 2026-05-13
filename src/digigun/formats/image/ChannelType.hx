package digigun.formats.image;

/**
 * Defines the storage type for one channel in an uncompressed pixel format.
 */
enum abstract ChannelType(String) from String to String {
  /** Unsigned normalized 8-bit integer. */
  var Unorm8 = "unorm8";

  /** Signed normalized 8-bit integer. */
  var Snorm8 = "snorm8";

  /** Unsigned 8-bit integer. */
  var Uint8 = "uint8";

  /** Signed 8-bit integer. */
  var Sint8 = "sint8";

  /** Unsigned normalized 16-bit integer. */
  var Unorm16 = "unorm16";

  /** Unsigned 16-bit integer. */
  var Uint16 = "uint16";

  /** IEEE-style 16-bit floating point. */
  var Float16 = "float16";

  /** IEEE-style 32-bit floating point. */
  var Float32 = "float32";

  /**
   * Returns the storage size of one channel in bytes.
   */
  public function bytesPerChannel():Int {
    return switch (this) {
      case Unorm8, Snorm8, Uint8, Sint8:
        1;
      case Unorm16, Uint16, Float16:
        2;
      case Float32:
        4;
      default:
        0;
    };
  }

  /**
   * Returns true when the channel type stores floating-point values.
   */
  public function isFloatingPoint():Bool {
    return switch (this) {
      case Float16, Float32:
        true;
      default:
        false;
    };
  }

  /**
   * Returns true when integer values are normalized to a unit range.
   */
  public function isNormalized():Bool {
    return switch (this) {
      case Unorm8, Snorm8, Unorm16:
        true;
      default:
        false;
    };
  }
}
