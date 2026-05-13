package digigun.formats.image;

/**
 * Describes a target-oriented texture compression decision.
 */
class TextureCompressionPlan {
  /** Graphics API family the result is intended for. */
  public var api(default, null):GraphicsApi;

  /** Preferred compressed pixel format for the target API. */
  public var format(default, null):PixelFormat;

  /** Preferred container format for the target API and pixel format. */
  public var container(default, null):TextureContainerFormat;

  /** Human-readable rationale for the recommendation. */
  public var reason(default, null):String;

  /**
   * Creates a new compression plan.
   */
  public function new(api:GraphicsApi, format:PixelFormat, container:TextureContainerFormat, reason:String) {
    this.api = api;
    this.format = format;
    this.container = container;
    this.reason = reason;
  }
}
