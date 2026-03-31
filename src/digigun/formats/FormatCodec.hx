package digigun.formats;

/**
 * Combines reading and writing into a single bidirectional format contract.
 *
 * @param TInput The raw input type consumed by `read`.
 * @param TValue The typed value exchanged by the codec.
 * @param TOutput The raw output type produced by `write`.
 */
interface FormatCodec<TInput, TValue, TOutput> extends FormatReader<TInput, TValue> extends FormatWriter<TValue, TOutput> {}
