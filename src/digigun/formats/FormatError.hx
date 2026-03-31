package digigun.formats;

/**
 * Structured error type shared by all format readers and writers.
 */
class FormatError {
  /** Machine-readable error category. */
  public final code:FormatErrorCode;
  /** Human-readable description of the failure. */
  public final message:String;
  /** Optional source position for text-based formats. */
  public final location:Null<FormatLocation>;
  /** Optional identifier of the format that raised the error. */
  public final formatId:Null<FormatId>;

  /**
   * Creates a new format error instance.
   */
  public function new(
    code:FormatErrorCode,
    message:String,
    ?location:FormatLocation,
    ?formatId:FormatId
  ) {
    this.code = code;
    this.message = message;
    this.location = location;
    this.formatId = formatId;
  }

  /**
   * Formats the error for logs and diagnostics.
   */
  public function toString():String {
    var parts = ['${code}: ${message}'];

    if (formatId != null) {
      parts.push('format=${formatId}');
    }

    if (location != null) {
      parts.push(location.toString());
    }

    return parts.join(" | ");
  }
}
