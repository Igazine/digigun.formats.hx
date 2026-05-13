package digigun.formats.image;

import haxe.io.Bytes;

/**
 * Mutable byte-buffer view over a `Bytes` instance.
 *
 * The buffer stores an offset and length so format implementations can work
 * with slices without copying underlying data unless they explicitly request
 * a detached `Bytes` value.
 */
class ByteBuffer {
  /** Backing bytes for this view. */
  public var bytes(default, null):Bytes;

  /** Starting offset within `bytes`. */
  public var offset(default, null):Int;

  /** Number of readable and writable bytes within this view. */
  public var length(default, null):Int;

  /**
   * Creates a new byte-buffer view.
   */
  public function new(bytes:Bytes, offset:Int = 0, ?length:Int) {
    if (offset < 0 || offset > bytes.length) {
      throw 'ByteBuffer offset out of bounds: ${offset}';
    }

    var resolvedLength = length == null ? bytes.length - offset : length;
    if (resolvedLength < 0 || offset + resolvedLength > bytes.length) {
      throw 'ByteBuffer length out of bounds: ${resolvedLength}';
    }

    this.bytes = bytes;
    this.offset = offset;
    this.length = resolvedLength;
  }

  /**
   * Allocates a new zero-filled buffer.
   */
  public static function alloc(length:Int):ByteBuffer {
    return new ByteBuffer(Bytes.alloc(length));
  }

  /**
   * Creates a full-view wrapper around existing bytes.
   */
  public static function wrap(bytes:Bytes):ByteBuffer {
    return new ByteBuffer(bytes);
  }

  /**
   * Reads one byte relative to this view.
   */
  public function get(index:Int):Int {
    assertIndex(index);
    return bytes.get(offset + index);
  }

  /**
   * Writes one byte relative to this view.
   */
  public function set(index:Int, value:Int):Void {
    assertIndex(index);
    bytes.set(offset + index, value);
  }

  /**
   * Creates another view over the same backing bytes.
   */
  public function slice(offset:Int, ?length:Int):ByteBuffer {
    if (offset < 0 || offset > this.length) {
      throw 'ByteBuffer slice offset out of bounds: ${offset}';
    }

    var resolvedLength = length == null ? this.length - offset : length;
    if (resolvedLength < 0 || offset + resolvedLength > this.length) {
      throw 'ByteBuffer slice length out of bounds: ${resolvedLength}';
    }

    return new ByteBuffer(bytes, this.offset + offset, resolvedLength);
  }

  /**
   * Copies the current view into a detached `Bytes` value.
   */
  public function toBytes():Bytes {
    return bytes.sub(offset, length);
  }

  /**
   * Fills the view with a single byte value.
   */
  public function fill(value:Int):Void {
    for (index in 0...length) {
      bytes.set(offset + index, value);
    }
  }

  /**
   * Returns the current view as lower-case hexadecimal text.
   */
  public function toHex():String {
    return toBytes().toHex().toLowerCase();
  }

  function assertIndex(index:Int):Void {
    if (index < 0 || index >= length) {
      throw 'ByteBuffer index out of bounds: ${index}';
    }
  }
}
