package digigun.formats.image;

/**
 * Result payload returned by GPU texture block encoders.
 */
class TextureBlockEncodingResult {
  /** Compression method used or planned for this output. */
  public var method(default, null):TextureCompressionMethod;

  /** Encoded texture data. */
  public var texture(default, null):TextureData;

  /** Whether the output reused the source data without re-encoding. */
  public var wasPassthrough(default, null):Bool;

  /** Human-readable explanation of what happened. */
  public var message(default, null):String;

  /**
   * Creates a new encoding result.
   */
  public function new(method:TextureCompressionMethod, texture:TextureData, wasPassthrough:Bool, message:String) {
    this.method = method;
    this.texture = texture;
    this.wasPassthrough = wasPassthrough;
    this.message = message;
  }
}
