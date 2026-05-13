package digigun.formats.image.tiff;

import digigun.formats.FormatError;
import digigun.formats.FormatErrorCode;
import digigun.formats.FormatReader;
import digigun.formats.FormatResult;
import digigun.formats.image.ImageSize;
import digigun.formats.image.PixelFormats;
import digigun.formats.image.TextureData;
import haxe.io.Bytes;

/**
 * Parses a practical uncompressed TIFF subset with one image and contiguous
 * interleaved samples.
 */
class TiffReader implements FormatReader<Bytes, TextureData> {
  static inline var TYPE_SHORT = 3;
  static inline var TYPE_LONG = 4;

  static inline var TAG_IMAGE_WIDTH = 256;
  static inline var TAG_IMAGE_LENGTH = 257;
  static inline var TAG_BITS_PER_SAMPLE = 258;
  static inline var TAG_COMPRESSION = 259;
  static inline var TAG_PHOTOMETRIC = 262;
  static inline var TAG_STRIP_OFFSETS = 273;
  static inline var TAG_SAMPLES_PER_PIXEL = 277;
  static inline var TAG_ROWS_PER_STRIP = 278;
  static inline var TAG_STRIP_BYTE_COUNTS = 279;
  static inline var TAG_PLANAR_CONFIGURATION = 284;

  /**
   * Creates a new TIFF reader.
   */
  public function new() {}

  /**
   * Parses one uncompressed TIFF image into texture data.
   */
  public function read(input:Bytes):FormatResult<TextureData> {
    if (input.length < 8) {
      return failure(FormatErrorCode.InvalidInput, "TIFF file is too small.");
    }

    var littleEndian = switch (input.getString(0, 2)) {
      case "II":
        true;
      case "MM":
        false;
      default:
        return failure(FormatErrorCode.InvalidInput, "TIFF byte-order marker is invalid.");
    }

    if (readUInt16(input, 2, littleEndian) != 42) {
      return failure(FormatErrorCode.InvalidInput, "TIFF magic number is invalid.");
    }

    var ifdOffset = readUInt32(input, 4, littleEndian);
    if (ifdOffset <= 0 || ifdOffset + 2 > input.length) {
      return failure(FormatErrorCode.InvalidStructure, "TIFF IFD offset is out of bounds.");
    }

    var entryCount = readUInt16(input, ifdOffset, littleEndian);
    var entriesOffset = ifdOffset + 2;
    if (entriesOffset + entryCount * 12 + 4 > input.length) {
      return failure(FormatErrorCode.InvalidStructure, "TIFF IFD entries are truncated.");
    }

    var width:Null<Int> = null;
    var height:Null<Int> = null;
    var bitsPerSample:Array<Int> = null;
    var compression = 1;
    var photometric:Null<Int> = null;
    var stripOffsets:Array<Int> = null;
    var samplesPerPixel = 1;
    var rowsPerStrip:Null<Int> = null;
    var stripByteCounts:Array<Int> = null;
    var planarConfiguration = 1;

    for (index in 0...entryCount) {
      var entryOffset = entriesOffset + index * 12;
      var tag = readUInt16(input, entryOffset, littleEndian);
      var fieldType = readUInt16(input, entryOffset + 2, littleEndian);
      var count = readUInt32(input, entryOffset + 4, littleEndian);
      var valueOffset = entryOffset + 8;

      switch (tag) {
        case TAG_IMAGE_WIDTH:
          width = readSingleInt(input, fieldType, count, valueOffset, littleEndian);
        case TAG_IMAGE_LENGTH:
          height = readSingleInt(input, fieldType, count, valueOffset, littleEndian);
        case TAG_BITS_PER_SAMPLE:
          bitsPerSample = readIntArray(input, fieldType, count, valueOffset, littleEndian);
        case TAG_COMPRESSION:
          compression = readSingleInt(input, fieldType, count, valueOffset, littleEndian);
        case TAG_PHOTOMETRIC:
          photometric = readSingleInt(input, fieldType, count, valueOffset, littleEndian);
        case TAG_STRIP_OFFSETS:
          stripOffsets = readIntArray(input, fieldType, count, valueOffset, littleEndian);
        case TAG_SAMPLES_PER_PIXEL:
          samplesPerPixel = readSingleInt(input, fieldType, count, valueOffset, littleEndian);
        case TAG_ROWS_PER_STRIP:
          rowsPerStrip = readSingleInt(input, fieldType, count, valueOffset, littleEndian);
        case TAG_STRIP_BYTE_COUNTS:
          stripByteCounts = readIntArray(input, fieldType, count, valueOffset, littleEndian);
        case TAG_PLANAR_CONFIGURATION:
          planarConfiguration = readSingleInt(input, fieldType, count, valueOffset, littleEndian);
        default:
      }
    }

    if (width == null || height == null || photometric == null || stripOffsets == null || stripByteCounts == null) {
      return failure(FormatErrorCode.InvalidStructure, "TIFF is missing required tags.");
    }

    if (compression != 1) {
      return failure(FormatErrorCode.UnsupportedFeature, "Only uncompressed TIFF files are supported.");
    }

    if (planarConfiguration != 1) {
      return failure(FormatErrorCode.UnsupportedFeature, "Only contiguous planar TIFF data is supported.");
    }

    if (rowsPerStrip == null) {
      rowsPerStrip = height;
    }

    if (samplesPerPixel <= 0) {
      return failure(FormatErrorCode.InvalidStructure, "TIFF samples-per-pixel must be positive.");
    }

    if (bitsPerSample == null) {
      bitsPerSample = [for (_ in 0...samplesPerPixel) 1];
    }

    if (bitsPerSample.length != samplesPerPixel) {
      return failure(FormatErrorCode.InvalidStructure, "TIFF bits-per-sample count does not match samples-per-pixel.");
    }

    for (bits in bitsPerSample) {
      if (bits != 8) {
        return failure(FormatErrorCode.UnsupportedFeature, "Only 8-bit TIFF samples are supported.");
      }
    }

    if (stripOffsets.length != stripByteCounts.length) {
      return failure(FormatErrorCode.InvalidStructure, "TIFF strip offset and byte-count arrays differ in length.");
    }

    var format = resolvePixelFormat(photometric, samplesPerPixel);
    if (format == null) {
      return failure(FormatErrorCode.UnsupportedFeature, "Unsupported TIFF sample layout.");
    }

    var expectedByteLength = width * height * samplesPerPixel;
    var pixelBytes = Bytes.alloc(expectedByteLength);
    var writeOffset = 0;

    for (index in 0...stripOffsets.length) {
      var offset = stripOffsets[index];
      var byteCount = stripByteCounts[index];
      if (offset < 0 || byteCount < 0 || offset + byteCount > input.length) {
        return failure(FormatErrorCode.InvalidStructure, "TIFF strip data is out of bounds.");
      }

      if (writeOffset + byteCount > expectedByteLength) {
        return failure(FormatErrorCode.InvalidStructure, "TIFF strip data exceeds the expected image length.");
      }

      pixelBytes.blit(writeOffset, input, offset, byteCount);
      writeOffset += byteCount;
    }

    if (writeOffset != expectedByteLength) {
      return failure(FormatErrorCode.InvalidStructure, "TIFF strip data does not fill the expected image length.");
    }

    return Success(TextureData.fromBytes2D(new ImageSize(width, height), format, pixelBytes));
  }

  function resolvePixelFormat(photometric:Int, samplesPerPixel:Int) {
    return switch ([photometric, samplesPerPixel]) {
      case [1, 1]:
        PixelFormats.R8_UNORM;
      case [2, 3]:
        PixelFormats.RGB8_UNORM;
      case [2, 4]:
        PixelFormats.RGBA8_UNORM;
      default:
        null;
    };
  }

  function readSingleInt(bytes:Bytes, fieldType:Int, count:Int, valueOffset:Int, littleEndian:Bool):Int {
    var values = readIntArray(bytes, fieldType, count, valueOffset, littleEndian);
    if (values.length != 1) {
      throw "Expected one TIFF value.";
    }
    return values[0];
  }

  function readIntArray(bytes:Bytes, fieldType:Int, count:Int, valueOffset:Int, littleEndian:Bool):Array<Int> {
    var typeSize = getTypeSize(fieldType);
    var valueBytes = count * typeSize;
    var dataOffset = valueBytes <= 4 ? valueOffset : readUInt32(bytes, valueOffset, littleEndian);
    if (dataOffset < 0 || dataOffset + valueBytes > bytes.length) {
      throw "TIFF value array is out of bounds.";
    }

    var values:Array<Int> = [];
    for (index in 0...count) {
      var itemOffset = dataOffset + index * typeSize;
      values.push(switch (fieldType) {
        case TYPE_SHORT:
          readUInt16(bytes, itemOffset, littleEndian);
        case TYPE_LONG:
          readUInt32(bytes, itemOffset, littleEndian);
        default:
          throw 'Unsupported TIFF field type: ${fieldType}';
      });
    }
    return values;
  }

  function getTypeSize(fieldType:Int):Int {
    return switch (fieldType) {
      case TYPE_SHORT:
        2;
      case TYPE_LONG:
        4;
      default:
        throw 'Unsupported TIFF field type: ${fieldType}';
    };
  }

  function failure(code:FormatErrorCode, message:String):FormatResult<TextureData> {
    return Failure(new FormatError(code, message, null, TiffFormat.id));
  }

  static function readUInt16(bytes:Bytes, offset:Int, littleEndian:Bool):Int {
    return if (littleEndian) {
      bytes.get(offset) | (bytes.get(offset + 1) << 8);
    } else {
      (bytes.get(offset) << 8) | bytes.get(offset + 1);
    };
  }

  static function readUInt32(bytes:Bytes, offset:Int, littleEndian:Bool):Int {
    return if (littleEndian) {
      bytes.get(offset)
        | (bytes.get(offset + 1) << 8)
        | (bytes.get(offset + 2) << 16)
        | (bytes.get(offset + 3) << 24);
    } else {
      (bytes.get(offset) << 24)
        | (bytes.get(offset + 1) << 16)
        | (bytes.get(offset + 2) << 8)
        | bytes.get(offset + 3);
    };
  }
}
