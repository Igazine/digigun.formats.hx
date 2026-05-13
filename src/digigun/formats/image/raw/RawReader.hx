package digigun.formats.image.raw;

import digigun.formats.FormatError;
import digigun.formats.FormatErrorCode;
import digigun.formats.FormatReader;
import digigun.formats.FormatResult;
import digigun.formats.image.TextureData;
import haxe.io.Bytes;

/**
 * Parses headerless raw bitmap bytes using an externally supplied specification.
 */
class RawReader implements FormatReader<Bytes, TextureData> {
  /** Layout used to interpret incoming bytes. */
  public var spec(default, null):RawImageSpec;

  /**
   * Creates a new RAW reader.
   */
  public function new(spec:RawImageSpec) {
    this.spec = spec;
  }

  /**
   * Wraps raw bytes into a `TextureData` instance when the byte count matches
   * the declared specification.
   */
  public function read(input:Bytes):FormatResult<TextureData> {
    var expectedLength = spec.expectedByteLength();
    if (input.length != expectedLength) {
      return Failure(new FormatError(
        FormatErrorCode.InvalidInput,
        'RAW byte length mismatch: expected ${expectedLength}, got ${input.length}',
        null,
        RawFormat.id
      ));
    }

    return Success(TextureData.fromBytes2D(spec.size, spec.format, input));
  }
}
