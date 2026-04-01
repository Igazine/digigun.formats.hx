package digigun.formats.hcl;

/**
 * Editable document model for the supported HCL2 subset.
 */
class HclDocument {
  /** Root body. */
  public final body:HclBody;

  /**
   * Creates a new HCL document.
   */
  public function new(?body:HclBody) {
    this.body = body == null ? new HclBody() : body;
  }
}

