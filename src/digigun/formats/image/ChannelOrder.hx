package digigun.formats.image;

/**
 * Defines the logical ordering of channels within a pixel.
 */
enum abstract ChannelOrder(String) from String to String {
  /** Single red or generic one-channel layout. */
  var R = "r";

  /** Two-channel layout, typically red/green. */
  var RG = "rg";

  /** Three-channel RGB layout. */
  var RGB = "rgb";

  /** Four-channel RGBA layout. */
  var RGBA = "rgba";

  /** Three-channel BGR layout. */
  var BGR = "bgr";

  /** Four-channel BGRA layout. */
  var BGRA = "bgra";

  /** Depth-only layout. */
  var Depth = "depth";

  /** Packed depth/stencil layout. */
  var DepthStencil = "depth-stencil";

  /**
   * Returns the channel count implied by this order.
   */
  public function channelCount():Int {
    return switch (this) {
      case R, Depth:
        1;
      case RG, DepthStencil:
        2;
      case RGB, BGR:
        3;
      case RGBA, BGRA:
        4;
      default:
        0;
    };
  }

  /**
   * Returns true when the layout includes an alpha channel.
   */
  public function hasAlpha():Bool {
    return switch (this) {
      case RGBA, BGRA:
        true;
      default:
        false;
    };
  }
}
