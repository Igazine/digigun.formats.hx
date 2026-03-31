package digigun.formats;

/**
 * Reads a typed value from a format-specific input representation.
 *
 * @param TInput The raw input type consumed by the reader.
 * @param TValue The strongly typed value produced on success.
 */
interface FormatReader<TInput, TValue> {
  /**
   * Attempts to read a typed value from the provided input.
   */
  public function read(input:TInput):FormatResult<TValue>;
}
