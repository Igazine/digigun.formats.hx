package digigun.formats.image;

import digigun.formats.FormatResult;

/**
 * Interface for GPU-oriented texture block encoders.
 */
interface TextureBlockEncoder {
  /** Compression method produced by this encoder. */
  public var method(get, never):TextureCompressionMethod;

  /** Output pixel format produced by this encoder. */
  public var outputFormat(get, never):PixelFormat;

  /**
   * Returns true when the encoder can accept the given source texture.
   */
  public function canEncode(source:TextureData, options:TextureBlockEncodingOptions):Bool;

  /**
   * Encodes a texture into the encoder's output format.
   */
  public function encode(source:TextureData, options:TextureBlockEncodingOptions):FormatResult<TextureBlockEncodingResult>;
}
