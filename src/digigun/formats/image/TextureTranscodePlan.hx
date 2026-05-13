package digigun.formats.image;

/**
 * Planning result for a future GPU texture encode or transcode step.
 */
class TextureTranscodePlan {
  /** Original request that produced this plan. */
  public var request(default, null):TextureEncodingRequest;

  /** Recommended output container. */
  public var container(default, null):TextureContainerFormat;

  /** Recommended output pixel format. */
  public var outputFormat(default, null):PixelFormat;

  /** Recommended compression method, or `None` for uncompressed output. */
  public var compressionMethod(default, null):TextureCompressionMethod;

  /** Whether a future block encoder is required to realize this plan. */
  public var requiresGpuEncoder(default, null):Bool;

  /** Human-readable explanation of the choice. */
  public var reason(default, null):String;

  /**
   * Creates a new transcode plan.
   */
  public function new(
    request:TextureEncodingRequest,
    container:TextureContainerFormat,
    outputFormat:PixelFormat,
    compressionMethod:TextureCompressionMethod,
    requiresGpuEncoder:Bool,
    reason:String
  ) {
    this.request = request;
    this.container = container;
    this.outputFormat = outputFormat;
    this.compressionMethod = compressionMethod;
    this.requiresGpuEncoder = requiresGpuEncoder;
    this.reason = reason;
  }
}
