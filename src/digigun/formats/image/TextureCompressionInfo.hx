package digigun.formats.image;

/**
 * Describes one GPU compression method and its output layout.
 */
class TextureCompressionInfo {
  /** Stable compression method identifier. */
  public var method(default, null):TextureCompressionMethod;

  /** Output pixel format produced by this compression method. */
  public var format(default, null):PixelFormat;

  /** Width of one encoded block in texels. */
  public var blockWidth(default, null):Int;

  /** Height of one encoded block in texels. */
  public var blockHeight(default, null):Int;

  /** Encoded byte size of one block. */
  public var blockBytes(default, null):Int;

  /** Human-readable description of the method. */
  public var description(default, null):String;

  /**
   * Creates a new compression description.
   */
  public function new(method:TextureCompressionMethod, format:PixelFormat, blockWidth:Int, blockHeight:Int, blockBytes:Int, description:String) {
    this.method = method;
    this.format = format;
    this.blockWidth = blockWidth;
    this.blockHeight = blockHeight;
    this.blockBytes = blockBytes;
    this.description = description;
  }
}
