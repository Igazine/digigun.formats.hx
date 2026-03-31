package digigun.formats;

/**
 * Lightweight wrapper for a media type string.
 */
abstract MediaType(String) from String to String {
  /**
   * Creates a new media type value.
   */
  public inline function new(value:String) {
    this = value;
  }
}
