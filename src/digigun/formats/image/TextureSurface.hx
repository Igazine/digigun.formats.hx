package digigun.formats.image;

/**
 * Stores one texture surface, such as a layer-face combination, and its mips.
 */
class TextureSurface {
  /** Zero-based array layer. */
  public var layer(default, null):Int;

  /** Zero-based face index, commonly 0 for 2D textures. */
  public var face(default, null):Int;

  /** Ordered mip levels for this surface. */
  public var mipLevels(default, null):Array<MipLevel>;

  /**
   * Creates a new texture surface descriptor.
   */
  public function new(layer:Int = 0, face:Int = 0, ?mipLevels:Array<MipLevel>) {
    if (layer < 0 || face < 0) {
      throw "Texture surface indices must be non-negative.";
    }

    this.layer = layer;
    this.face = face;
    this.mipLevels = mipLevels == null ? [] : mipLevels;
  }

  /**
   * Returns the mip level for the given index, or null when missing.
   */
  public function getMipLevel(level:Int):Null<MipLevel> {
    for (item in mipLevels) {
      if (item.level == level) {
        return item;
      }
    }

    return null;
  }

  /**
   * Adds or replaces a mip level by index.
   */
  public function setMipLevel(value:MipLevel):Void {
    for (index in 0...mipLevels.length) {
      if (mipLevels[index].level == value.level) {
        mipLevels[index] = value;
        return;
      }
    }

    mipLevels.push(value);
    mipLevels.sort(function(left, right) return left.level - right.level);
  }

  /**
   * Returns the total byte size of all stored mip levels.
   */
  public function totalByteLength():Int {
    var total = 0;
    for (level in mipLevels) {
      total += level.data.length;
    }
    return total;
  }
}
