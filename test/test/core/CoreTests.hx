package test.core;

import digigun.formats.FormatCodec;
import digigun.formats.FormatError;
import digigun.formats.FormatErrorCode;
import digigun.formats.FormatLocation;
import digigun.formats.FormatResult;
import digigun.formats.text.ini.IniCodec;
import digigun.formats.text.ini.IniDocument;
import test.Assertions;

class CoreTests {
  public static function run():Void {
    testFormatResult();
    testFormatError();
    testReaderWriterTyping();
  }

  static function testFormatResult():Void {
    var result:FormatResult<Int> = Success(42);

    switch (result) {
      case Success(value):
        Assertions.assertEquals("format result success", 42, value);
      case Failure(_):
        Assertions.fail("Expected success result.");
    }

    var failure:FormatResult<Int> = Failure(new FormatError(FormatErrorCode.InvalidInput, "bad value"));
    switch (failure) {
      case Failure(error):
        Assertions.assertEquals("format result failure code", FormatErrorCode.InvalidInput, error.code);
      case Success(_):
        Assertions.fail("Expected failure result.");
    }
  }

  static function testFormatError():Void {
    var error = new FormatError(FormatErrorCode.InvalidStructure, "Broken structure", new FormatLocation(3, 7));
    Assertions.assertEquals("error code", FormatErrorCode.InvalidStructure, error.code);
    Assertions.assertEquals("error location line", 3, error.location.line);
    Assertions.assertTrue("error toString contains message", error.toString().indexOf("Broken structure") >= 0);
  }

  static function testReaderWriterTyping():Void {
    var codec:FormatCodec<String, IniDocument, String> = new IniCodec();

    switch (codec.read("enabled = true")) {
      case Success(document):
        Assertions.assertEquals("typed codec read global properties", 1, document.globalProperties.length);
      case Failure(error):
        Assertions.fail('Expected typed codec read to succeed: ${error.toString()}');
    }
  }
}
