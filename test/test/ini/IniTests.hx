package test.ini;

import digigun.formats.FormatErrorCode;
import digigun.formats.ini.IniCodec;
import digigun.formats.ini.IniDocument;
import digigun.formats.ini.IniProperty;
import digigun.formats.ini.IniReader;
import digigun.formats.ini.IniSection;
import digigun.formats.ini.IniValues;
import test.Assertions;
import test.FixtureTools;

class IniTests {
  public static function run():Void {
    testIniParsing();
    testIniRoundTrip();
    testIniAmbiguousStringRoundTrip();
    testInvalidIni();
    testValueConversions();
    testImplicitValueConstruction();
    testMutableIniEditing();
    testInvalidIniSectionHeader();
  }

  static function testIniParsing():Void {
    var source = FixtureTools.text("ini/parse.ini");
    var reader = new IniReader();

    switch (reader.read(source)) {
      case Success(document):
        Assertions.assertEquals("global property count", 1, document.globalProperties.length);
        Assertions.assertEquals("section count", 1, document.sections.length);
        Assertions.assertEquals("section property count", 4, document.sections[0].properties.length);
      case Failure(error):
        Assertions.fail('Expected INI parse to succeed: ${error.toString()}');
    }
  }

  static function testIniRoundTrip():Void {
    var document = new IniDocument(
      [new IniProperty("name", "digigun")],
      [new IniSection("app", [new IniProperty("enabled", true), new IniProperty("threshold", 2.5)])]
    );
    var codec = new IniCodec();

    var serialized = switch (codec.write(document)) {
      case Success(value):
        value;
      case Failure(error):
        Assertions.fail('Expected write to succeed: ${error.toString()}');
        "";
    };

    Assertions.assertEquals("ini serialized fixture", FixtureTools.text("ini/serialize.ini"), serialized);

    switch (codec.read(serialized)) {
      case Success(parsed):
        Assertions.assertEquals("round trip global property count", 1, parsed.globalProperties.length);
        Assertions.assertEquals("round trip section count", 1, parsed.sections.length);
      case Failure(error):
        Assertions.fail('Expected round trip parse to succeed: ${error.toString()}');
    }
  }

  static function testInvalidIni():Void {
    var reader = new IniReader();
    switch (reader.read("= value")) {
      case Failure(error):
        Assertions.assertEquals("invalid ini code", FormatErrorCode.InvalidStructure, error.code);
      case Success(_):
        Assertions.fail("Expected malformed ini to fail.");
    }
  }

  static function testIniAmbiguousStringRoundTrip():Void {
    var document = new IniDocument();
    document.setGlobalProperty("bool_text", "true");
    document.setGlobalProperty("int_text", "123");
    document.setGlobalProperty("float_text", "1.5");
    document.setGlobalProperty("spaced_text", "hello world");

    var codec = new IniCodec();
    var serialized = switch (codec.write(document)) {
      case Success(value):
        value;
      case Failure(error):
        Assertions.fail('Expected INI ambiguity write to succeed: ${error.toString()}');
        "";
    };

    switch (codec.read(serialized)) {
      case Success(parsed):
        Assertions.assertEquals("ini ambiguous bool string", "true", parsed.getGlobalProperty("bool_text").value.asString());
        Assertions.assertEquals("ini ambiguous int string", "123", parsed.getGlobalProperty("int_text").value.asString());
        Assertions.assertEquals("ini ambiguous float string", "1.5", parsed.getGlobalProperty("float_text").value.asString());
        Assertions.assertEquals("ini ambiguous spaced string", "hello world", parsed.getGlobalProperty("spaced_text").value.asString());
      case Failure(error):
        Assertions.fail('Expected INI ambiguity round trip to succeed: ${error.toString()}');
    }
  }

  static function testValueConversions():Void {
    Assertions.assertEquals("int conversion", 5, IniValues.asInt(IniValues.ofInt(5)));
    Assertions.assertFloatEquals("float conversion from float", 1.5, IniValues.asFloat(IniValues.ofFloat(1.5)));
    Assertions.assertFloatEquals("float conversion from int", 5.0, IniValues.asFloat(IniValues.ofInt(5)));
    Assertions.assertEquals("bool conversion", true, IniValues.asBool(IniValues.ofBool(true)));
    Assertions.assertEquals("string conversion", "5", IniValues.asString(IniValues.ofInt(5)));
  }

  static function testImplicitValueConstruction():Void {
    var iniProperty = new IniProperty("retries", 3);
    Assertions.assertEquals("ini implicit int conversion", 3, iniProperty.value.asInt());
  }

  static function testMutableIniEditing():Void {
    var document = new IniDocument();
    document.setGlobalProperty("name", "digigun");

    var section = document.getOrCreateSection("app");
    section.setProperty("enabled", true);
    section.setProperty("retries", 3);
    section.setProperty("retries", 4);

    Assertions.assertEquals("mutable ini global property", "digigun", document.getGlobalProperty("name").value.asString());
    Assertions.assertEquals("mutable ini updated property", 4, section.getProperty("retries").value.asInt());
    Assertions.assertTrue("mutable ini remove property", section.removeProperty("enabled"));
    Assertions.assertTrue("mutable ini remove section", document.removeSection("app"));
    Assertions.assertTrue("mutable ini section removed", !document.hasSection("app"));
  }

  static function testInvalidIniSectionHeader():Void {
    var reader = new IniReader();
    switch (reader.read("[app")) {
      case Failure(error):
        Assertions.assertEquals("invalid ini section header code", FormatErrorCode.InvalidStructure, error.code);
      case Success(_):
        Assertions.fail("Expected malformed INI section header to fail.");
    }
  }
}
