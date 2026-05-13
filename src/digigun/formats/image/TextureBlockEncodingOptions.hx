package digigun.formats.image;

/**
 * Options for future GPU block-encoding work.
 */
class TextureBlockEncodingOptions {
  /** Whether the encoder may return the source texture unchanged when it already matches the target format. */
  public var allowPassthrough(default, null):Bool;

  /** Whether mipmaps should be generated when the source texture does not already contain them. */
  public var generateMipmaps(default, null):Bool;

  /** Quality hint in the range 0-100 for future encoder implementations. */
  public var quality(default, null):Int;

  /**
   * Creates a new set of encoding options.
   */
  public function new(allowPassthrough:Bool = true, generateMipmaps:Bool = false, quality:Int = 75) {
    this.allowPassthrough = allowPassthrough;
    this.generateMipmaps = generateMipmaps;
    this.quality = quality;
  }
}
