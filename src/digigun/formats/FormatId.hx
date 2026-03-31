package digigun.formats;

/**
 * Lightweight identifier for a concrete format implementation.
 */
abstract FormatId(String) from String to String {
  /**
   * Creates a new format identifier from a string value.
   */
  public inline function new(value:String) {
    this = value;
  }
}
