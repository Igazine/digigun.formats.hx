package digigun.formats;

/**
 * Result type returned by all readers and writers in the library.
 */
enum FormatResult<T> {
  /**
   * Represents a successful read or write operation.
   */
  Success(value:T);
  /**
   * Represents a failed read or write operation.
   */
  Failure(error:FormatError);
}
