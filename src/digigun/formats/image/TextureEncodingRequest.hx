package digigun.formats.image;

/**
 * Describes a desired output target for future GPU texture encoding.
 */
class TextureEncodingRequest {
  /** Graphics API family the texture is being prepared for. */
  public var api(default, null):GraphicsApi;

  /** Source texture data to encode or transcode. */
  public var source(default, null):TextureData;

  /** Whether alpha support is required in the output. */
  public var requireAlpha(default, null):Bool;

  /** Whether the output should preserve or target sRGB semantics. */
  public var preferSrgb(default, null):Bool;

  /** Whether uncompressed output is allowed when compression is unavailable. */
  public var allowUncompressedFallback(default, null):Bool;

  /** Optional preferred output container. */
  public var preferredContainer(default, null):Null<TextureContainerFormat>;

  /**
   * Creates a new encoding request.
   */
  public function new(
    api:GraphicsApi,
    source:TextureData,
    requireAlpha:Bool = true,
    preferSrgb:Bool = false,
    allowUncompressedFallback:Bool = true,
    ?preferredContainer:TextureContainerFormat
  ) {
    this.api = api;
    this.source = source;
    this.requireAlpha = requireAlpha;
    this.preferSrgb = preferSrgb;
    this.allowUncompressedFallback = allowUncompressedFallback;
    this.preferredContainer = preferredContainer;
  }
}
