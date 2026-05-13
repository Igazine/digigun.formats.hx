package digigun.formats.image.raw;

import digigun.formats.FormatError;
import digigun.formats.FormatErrorCode;
import digigun.formats.FormatResult;
import digigun.formats.FormatWriter;
import digigun.formats.image.TextureData;
import digigun.formats.image.TextureDimension;
import haxe.io.Bytes;

/**
 * Serializes a simple 2D texture back into headerless raw bytes.
 */
class RawWriter implements FormatWriter<TextureData, Bytes> {
  /** Layout required for outgoing bytes. */
  public var spec(default, null):RawImageSpec;

  /**
   * Creates a new RAW writer.
   */
  public function new(spec:RawImageSpec) {
    this.spec = spec;
  }

  /**
   * Serializes the primary mip level of a 2D texture when it matches the
   * configured RAW specification.
   */
  public function write(value:TextureData):FormatResult<Bytes> {
    if (value.dimension != TextureDimension.Texture2D) {
      return Failure(error("RAW writing currently supports only 2D textures."));
    }

    if (value.format.id != spec.format.id) {
      return Failure(error('RAW format mismatch: expected ${spec.format.id}, got ${value.format.id}'));
    }

    if (value.size.width != spec.size.width || value.size.height != spec.size.height || value.size.depth != spec.size.depth) {
      return Failure(error("RAW size mismatch."));
    }

    var mip = value.getPrimaryMipLevel();
    if (mip == null) {
      return Failure(error("RAW texture has no primary mip level."));
    }

    if (mip.data.length != spec.expectedByteLength()) {
      return Failure(error('RAW byte length mismatch: expected ${spec.expectedByteLength()}, got ${mip.data.length}'));
    }

    return Success(mip.data.toBytes());
  }

  function error(message:String):FormatError {
    return new FormatError(FormatErrorCode.InvalidInput, message, null, RawFormat.id);
  }
}
