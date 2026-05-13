package digigun.formats.image;

/**
 * Describes the practical capabilities of one texture container format.
 */
class TextureContainerProfile {
  /** Container identifier. */
  public var container(default, null):TextureContainerFormat;

  /** Whether the container naturally supports mip chains. */
  public var supportsMipmaps(default, null):Bool;

  /** Whether the container naturally supports GPU-compressed payloads. */
  public var supportsCompressedFormats(default, null):Bool;

  /** Built-in pixel format identifiers that the library currently maps well into this container. */
  public var supportedFormatIds(default, null):Array<String>;

  /**
   * Creates a new container profile.
   */
  public function new(container:TextureContainerFormat, supportsMipmaps:Bool, supportsCompressedFormats:Bool, supportedFormatIds:Array<String>) {
    this.container = container;
    this.supportsMipmaps = supportsMipmaps;
    this.supportsCompressedFormats = supportsCompressedFormats;
    this.supportedFormatIds = supportedFormatIds;
  }
}
