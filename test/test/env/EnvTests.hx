package test.env;

import digigun.formats.FormatErrorCode;
import digigun.formats.env.EnvCodec;
import digigun.formats.env.EnvDocument;
import digigun.formats.env.EnvReader;
import test.Assertions;

class EnvTests {
  public static function run():Void {
    testEnvParsing();
    testEnvRoundTrip();
    testMutableEnvEditing();
    testInvalidEnv();
  }

  static function testEnvParsing():Void {
    var reader = new EnvReader();
    var source = '# comment
export APP_NAME="digigun formats"
PORT=8080';

    switch (reader.read(source)) {
      case Success(document):
        Assertions.assertEquals("env entry count", 2, document.entries.length);
        Assertions.assertEquals("env parsed exported value", "digigun formats", document.getProperty("APP_NAME").value);
        Assertions.assertEquals("env parsed port", "8080", document.getProperty("PORT").value);
      case Failure(error):
        Assertions.fail('Expected env parse to succeed: ${error.toString()}');
    }
  }

  static function testEnvRoundTrip():Void {
    var document = new EnvDocument();
    document.setProperty("APP_NAME", "digigun formats", true);
    document.setProperty("PORT", "8080");
    var codec = new EnvCodec();

    var serialized = switch (codec.write(document)) {
      case Success(value):
        value;
      case Failure(error):
        Assertions.fail('Expected env write to succeed: ${error.toString()}');
        "";
    };

    switch (codec.read(serialized)) {
      case Success(parsed):
        Assertions.assertEquals("env round trip entry count", 2, parsed.entries.length);
        Assertions.assertEquals("env round trip exported", true, parsed.getProperty("APP_NAME").exported);
      case Failure(error):
        Assertions.fail('Expected env round trip parse to succeed: ${error.toString()}');
    }
  }

  static function testMutableEnvEditing():Void {
    var document = new EnvDocument();
    document.setProperty("APP_NAME", "digigun", true);
    document.setProperty("APP_NAME", "igazine", false);

    Assertions.assertTrue("mutable env has property", document.hasProperty("APP_NAME"));
    Assertions.assertEquals("mutable env updated value", "igazine", document.getProperty("APP_NAME").value);
    Assertions.assertEquals("mutable env updated exported", false, document.getProperty("APP_NAME").exported);
    Assertions.assertTrue("mutable env remove", document.removeProperty("APP_NAME"));
    Assertions.assertTrue("mutable env removed", !document.hasProperty("APP_NAME"));
  }

  static function testInvalidEnv():Void {
    var reader = new EnvReader();
    switch (reader.read("BROKEN")) {
      case Failure(error):
        Assertions.assertEquals("invalid env code", FormatErrorCode.InvalidStructure, error.code);
      case Success(_):
        Assertions.fail("Expected malformed env to fail.");
    }
  }
}
