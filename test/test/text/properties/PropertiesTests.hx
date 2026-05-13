package test.text.properties;

import digigun.formats.FormatErrorCode;
import digigun.formats.text.properties.PropertiesCodec;
import digigun.formats.text.properties.PropertiesDocument;
import digigun.formats.text.properties.PropertiesReader;
import test.Assertions;
import test.FixtureTools;

class PropertiesTests {
  public static function run():Void {
    testPropertiesParsing();
    testPropertiesRoundTrip();
    testPropertiesEscapedDelimiters();
    testPropertiesDelimiterRoundTrip();
    testMutablePropertiesEditing();
    testInvalidProperties();
  }

  static function testPropertiesParsing():Void {
    var reader = new PropertiesReader();
    var source = FixtureTools.text("text/properties/parse.properties");

    switch (reader.read(source)) {
      case Success(document):
        Assertions.assertEquals("properties entry count", 2, document.entries.length);
        Assertions.assertEquals("properties parsed value", "clean", document.getProperty("theme").value);
      case Failure(error):
        Assertions.fail('Expected properties parse to succeed: ${error.toString()}');
    }
  }

  static function testPropertiesRoundTrip():Void {
    var document = new PropertiesDocument();
    document.setProperty("name", "digigun");
    document.setProperty("theme", "clean");
    var codec = new PropertiesCodec();

    var serialized = switch (codec.write(document)) {
      case Success(value):
        value;
      case Failure(error):
        Assertions.fail('Expected properties write to succeed: ${error.toString()}');
        "";
    };

    Assertions.assertEquals("properties serialized fixture", FixtureTools.text("text/properties/serialize.properties"), serialized);

    switch (codec.read(serialized)) {
      case Success(parsed):
        Assertions.assertEquals("properties round trip entry count", 2, parsed.entries.length);
        Assertions.assertEquals("properties round trip theme", "clean", parsed.getProperty("theme").value);
      case Failure(error):
        Assertions.fail('Expected properties round trip parse to succeed: ${error.toString()}');
    }
  }

  static function testMutablePropertiesEditing():Void {
    var document = new PropertiesDocument();
    document.setProperty("name", "digigun");
    document.setProperty("name", "igazine");

    Assertions.assertTrue("mutable properties has property", document.hasProperty("name"));
    Assertions.assertEquals("mutable properties updated value", "igazine", document.getProperty("name").value);
    Assertions.assertTrue("mutable properties remove", document.removeProperty("name"));
    Assertions.assertTrue("mutable properties removed", !document.hasProperty("name"));
  }

  static function testPropertiesEscapedDelimiters():Void {
    var reader = new PropertiesReader();
    var source = 'db\\=name=digigun\\:formats\npath=C\\:\\\\tools\n';

    switch (reader.read(source)) {
      case Success(document):
        Assertions.assertEquals("properties escaped delimiter key", "digigun:formats", document.getProperty("db=name").value);
        Assertions.assertEquals("properties escaped delimiter value", "C:\\tools", document.getProperty("path").value);
      case Failure(error):
        Assertions.fail('Expected properties escaped delimiters to succeed: ${error.toString()}');
    }
  }

  static function testPropertiesDelimiterRoundTrip():Void {
    var document = new PropertiesDocument();
    document.setProperty("db=name", "digigun:formats");
    document.setProperty("path", "C:\\tools");
    var codec = new PropertiesCodec();

    var serialized = switch (codec.write(document)) {
      case Success(value):
        value;
      case Failure(error):
        Assertions.fail('Expected properties delimiter write to succeed: ${error.toString()}');
        "";
    };

    switch (codec.read(serialized)) {
      case Success(parsed):
        Assertions.assertEquals("properties delimiter round trip value", "digigun:formats", parsed.getProperty("db=name").value);
        Assertions.assertEquals("properties delimiter round trip path", "C:\\tools", parsed.getProperty("path").value);
      case Failure(error):
        Assertions.fail('Expected properties delimiter round trip parse to succeed: ${error.toString()}');
    }
  }

  static function testInvalidProperties():Void {
    var reader = new PropertiesReader();
    switch (reader.read("=broken")) {
      case Failure(error):
        Assertions.assertEquals("invalid properties code", FormatErrorCode.InvalidStructure, error.code);
      case Success(_):
        Assertions.fail("Expected malformed properties to fail.");
    }
  }
}
