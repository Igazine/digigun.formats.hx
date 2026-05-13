package digigun.formats.image;

/**
 * Describes either an uncompressed pixel layout or a compressed block format.
 */
class PixelFormat {
  /** Stable string identifier for the format. */
  public var id(default, null):String;

  /** Channel ordering for uncompressed formats, or null for pure block formats. */
  public var channelOrder(default, null):Null<ChannelOrder>;

  /** Channel storage type for uncompressed formats, or null for block formats. */
  public var channelType(default, null):Null<ChannelType>;

  /** Color space used by the format. */
  public var colorSpace(default, null):ColorSpace;

  /** Compression family for block formats, or null for uncompressed formats. */
  public var compressedFamily(default, null):Null<CompressedFormatFamily>;

  /** Width of one compressed block in texels. */
  public var blockWidth(default, null):Int;

  /** Height of one compressed block in texels. */
  public var blockHeight(default, null):Int;

  /** Size of one compressed block in bytes, or 0 for uncompressed formats. */
  public var blockBytes(default, null):Int;

  /**
   * Creates a new pixel-format descriptor.
   */
  public function new(
    id:String,
    ?channelOrder:ChannelOrder,
    ?channelType:ChannelType,
    colorSpace:ColorSpace = ColorSpace.Linear,
    ?compressedFamily:CompressedFormatFamily,
    blockWidth:Int = 1,
    blockHeight:Int = 1,
    blockBytes:Int = 0
  ) {
    this.id = id;
    this.channelOrder = channelOrder;
    this.channelType = channelType;
    this.colorSpace = colorSpace;
    this.compressedFamily = compressedFamily;
    this.blockWidth = blockWidth;
    this.blockHeight = blockHeight;
    this.blockBytes = blockBytes;
  }

  /**
   * Returns true when the format uses block compression.
   */
  public function isCompressed():Bool {
    return compressedFamily != null;
  }

  /**
   * Returns the bytes per pixel for uncompressed formats, or null when the
   * format is compressed.
   */
  public function bytesPerPixel():Null<Int> {
    if (channelOrder == null || channelType == null || isCompressed()) {
      return null;
    }

    return channelOrder.channelCount() * channelType.bytesPerChannel();
  }

  /**
   * Returns the byte size of one mip level with the given size.
   */
  public function byteLengthFor(size:ImageSize):Int {
    if (isCompressed()) {
      var blocksWide = Std.int(Math.ceil(size.width / blockWidth));
      var blocksHigh = Std.int(Math.ceil(size.height / blockHeight));
      return blocksWide * blocksHigh * size.depth * blockBytes;
    }

    var pixelBytes:Int = bytesPerPixel();
    return size.pixelCount() * pixelBytes;
  }
}
