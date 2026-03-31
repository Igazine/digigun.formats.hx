package digigun.formats;

/**
 * Writes a typed value into a format-specific output representation.
 *
 * @param TValue The strongly typed value accepted by the writer.
 * @param TOutput The raw output type produced on success.
 */
interface FormatWriter<TValue, TOutput> {
  /**
   * Attempts to serialize the provided value.
   */
  public function write(value:TValue):FormatResult<TOutput>;
}
