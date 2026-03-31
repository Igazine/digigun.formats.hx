package digigun.formats;

/**
 * Machine-readable error categories for format operations.
 */
enum abstract FormatErrorCode(String) from String to String {
  /** Input could not be accepted in its current form. */
  var InvalidInput = "invalid_input";
  /** Input structure does not match the expected syntax. */
  var InvalidStructure = "invalid_structure";
  /** A specific value is malformed or unsupported for its field. */
  var InvalidValue = "invalid_value";
  /** The requested feature is intentionally not supported by the implementation. */
  var UnsupportedFeature = "unsupported_feature";
  /** Serialization failed while producing output. */
  var WriteFailure = "write_failure";
}
