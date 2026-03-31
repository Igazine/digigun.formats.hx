package test.toml;

import digigun.formats.FormatErrorCode;
import digigun.formats.toml.TomlCodec;
import digigun.formats.toml.TomlDocument;
import digigun.formats.toml.TomlProperty;
import digigun.formats.toml.TomlReader;
import digigun.formats.toml.TomlTable;
import digigun.formats.toml.TomlValue;
import digigun.formats.toml.TomlValues;
import test.Assertions;

class TomlTests {
  public static function run():Void {
    testTomlParsing();
    testTomlRoundTrip();
    testInvalidToml();
    testTomlValueConversions();
    testImplicitValueConstruction();
    testMutableTomlEditing();
  }

  static function testTomlParsing():Void {
    var source = '# comment
title = "digigun.formats"
ports = [80, 443]

[server]
enabled = true
threshold = 2.5';
    var reader = new TomlReader();

    switch (reader.read(source)) {
      case Success(document):
        Assertions.assertEquals("toml global property count", 2, document.globalProperties.length);
        Assertions.assertEquals("toml table count", 1, document.tables.length);
        Assertions.assertEquals("toml table property count", 2, document.tables[0].properties.length);
        var ports = TomlValues.asArray(document.globalProperties[1].value);
        Assertions.assertEquals("toml array item count", 2, ports.length);
      case Failure(error):
        Assertions.fail('Expected TOML parse to succeed: ${error.toString()}');
    }
  }

  static function testTomlRoundTrip():Void {
    var document = new TomlDocument(
      [new TomlProperty("title", "digigun.formats"), new TomlProperty("ports", [80, 443])],
      [new TomlTable("server", [new TomlProperty("enabled", true), new TomlProperty("threshold", 2.5)])]
    );
    var codec = new TomlCodec();

    var serialized = switch (codec.write(document)) {
      case Success(value):
        value;
      case Failure(error):
        Assertions.fail('Expected TOML write to succeed: ${error.toString()}');
        "";
    };

    Assertions.assertTrue("serialized toml includes table", serialized.indexOf("[server]") >= 0);

    switch (codec.read(serialized)) {
      case Success(parsed):
        Assertions.assertEquals("toml round trip global property count", 2, parsed.globalProperties.length);
        Assertions.assertEquals("toml round trip table count", 1, parsed.tables.length);
      case Failure(error):
        Assertions.fail('Expected TOML round trip parse to succeed: ${error.toString()}');
    }
  }

  static function testInvalidToml():Void {
    var reader = new TomlReader();
    switch (reader.read("title = bareword")) {
      case Failure(error):
        Assertions.assertEquals("invalid toml code", FormatErrorCode.UnsupportedFeature, error.code);
      case Success(_):
        Assertions.fail("Expected unsupported TOML value to fail.");
    }
  }

  static function testTomlValueConversions():Void {
    var intValue:TomlValue = 5;
    var floatValue:TomlValue = 1.5;
    var boolValue:TomlValue = true;
    var arrayValue:TomlValue = [1, 2];

    Assertions.assertEquals("toml int conversion", 5, intValue.asInt());
    Assertions.assertFloatEquals("toml float conversion", 1.5, floatValue.asFloat());
    Assertions.assertEquals("toml bool conversion", true, boolValue.asBool());
    Assertions.assertEquals("toml string conversion", "5", intValue.asString());
    Assertions.assertEquals("toml array conversion size", 2, arrayValue.asArray().length);
  }

  static function testImplicitValueConstruction():Void {
    var tomlProperty = new TomlProperty("ports", [12, 13, 14]);
    Assertions.assertEquals("toml implicit array conversion", 3, tomlProperty.value.asArray().length);
  }

  static function testMutableTomlEditing():Void {
    var document = new TomlDocument();
    document.setGlobalProperty("title", "digigun.formats");

    var table = document.getOrCreateTable("server");
    table.setProperty("ports", [80, 443]);
    table.setProperty("enabled", true);
    table.setProperty("enabled", false);

    Assertions.assertEquals("mutable toml global property", "digigun.formats", document.getGlobalProperty("title").value.asString());
    Assertions.assertEquals("mutable toml updated bool", false, table.getProperty("enabled").value.asBool());
    Assertions.assertEquals("mutable toml array size", 2, table.getProperty("ports").value.asArray().length);
    Assertions.assertTrue("mutable toml remove property", table.removeProperty("enabled"));
    Assertions.assertTrue("mutable toml remove table", document.removeTable("server"));
    Assertions.assertTrue("mutable toml table removed", !document.hasTable("server"));
  }
}
