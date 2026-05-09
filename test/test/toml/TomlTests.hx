package test.toml;

import digigun.formats.FormatErrorCode;
import digigun.formats.toml.TomlCodec;
import digigun.formats.toml.TomlDocument;
import digigun.formats.toml.TomlObject;
import digigun.formats.toml.TomlProperty;
import digigun.formats.toml.TomlReader;
import digigun.formats.toml.TomlTable;
import digigun.formats.toml.TomlValue;
import digigun.formats.toml.TomlValues;
import test.Assertions;
import test.FixtureTools;

class TomlTests {
  public static function run():Void {
    testTomlParsing();
    testTomlEdgeFixture();
    testTomlSampleFixture();
    testTomlRoundTrip();
    testNestedInlineTables();
    testInvalidTomlInlineTableStructure();
    testUnsupportedTomlQuotedKeys();
    testInvalidToml();
    testTomlValueConversions();
    testImplicitValueConstruction();
    testMutableTomlEditing();
  }

  static function testTomlParsing():Void {
    var source = FixtureTools.text("toml/parse.toml");
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
      [new TomlTable("server", [new TomlProperty("enabled", true), new TomlProperty("threshold", 2.5), new TomlProperty("metadata", createMetadataObject())])]
    );
    var codec = new TomlCodec();

    var serialized = switch (codec.write(document)) {
      case Success(value):
        value;
      case Failure(error):
        Assertions.fail('Expected TOML write to succeed: ${error.toString()}');
        "";
    };

    Assertions.assertEquals("toml serialized fixture", FixtureTools.text("toml/serialize.toml"), serialized);

    switch (codec.read(serialized)) {
      case Success(parsed):
        Assertions.assertEquals("toml round trip global property count", 2, parsed.globalProperties.length);
        Assertions.assertEquals("toml round trip table count", 1, parsed.tables.length);
        Assertions.assertEquals("toml round trip inline object field", "digigun", parsed.getTable("server").getProperty("metadata").value.asObject().getField("owner").value.asString());
      case Failure(error):
        Assertions.fail('Expected TOML round trip parse to succeed: ${error.toString()}');
    }
  }

  static function testTomlEdgeFixture():Void {
    var reader = new TomlReader();
    var source = FixtureTools.text("toml/edge.toml");

    switch (reader.read(source)) {
      case Success(document):
        Assertions.assertEquals("toml edge empty string", "", document.getGlobalProperty("empty").value.asString());
        Assertions.assertEquals("toml edge flags size", 2, document.getGlobalProperty("flags").value.asArray().length);
        Assertions.assertEquals("toml edge quoted hash", "hello # not comment", document.getTable("server").getProperty("message").value.asString());
        Assertions.assertEquals("toml edge inline object owner", "digigun", document.getTable("server").getProperty("metadata").value.asObject().getField("owner").value.asString());
      case Failure(error):
        Assertions.fail('Expected TOML edge fixture to succeed: ${error.toString()}');
    }
  }

  static function testTomlSampleFixture():Void {
    var reader = new TomlReader();
    var source = FixtureTools.text("toml/sample.toml");

    switch (reader.read(source)) {
      case Success(document):
        Assertions.assertEquals("toml sample authors size", 2, document.getGlobalProperty("authors").value.asArray().length);
        Assertions.assertEquals("toml sample project version", "0.1.0", document.getTable("project").getProperty("version").value.asString());
        Assertions.assertEquals("toml sample ci jobs size", 2, document.getTable("ci").getProperty("jobs").value.asArray().length);
      case Failure(error):
        Assertions.fail('Expected TOML sample fixture to succeed: ${error.toString()}');
    }
  }

  static function testNestedInlineTables():Void {
    var reader = new TomlReader();
    var source = 'metadata = { owner = "digigun", nested = { team = "engine", active = true }, matrix = [[1, 2], [3, 4]], empty = {} }';

    switch (reader.read(source)) {
      case Success(document):
        var metadata = document.getGlobalProperty("metadata").value.asObject();
        Assertions.assertEquals("toml nested inline table owner", "digigun", metadata.getField("owner").value.asString());
        Assertions.assertEquals("toml nested inline table field", "engine", metadata.getField("nested").value.asObject().getField("team").value.asString());
        Assertions.assertEquals("toml nested inline bool", true, metadata.getField("nested").value.asObject().getField("active").value.asBool());
        Assertions.assertEquals("toml nested inline matrix outer size", 2, metadata.getField("matrix").value.asArray().length);
        Assertions.assertEquals("toml nested inline matrix inner value", 4, metadata.getField("matrix").value.asArray()[1].asArray()[1].asInt());
        Assertions.assertEquals("toml nested inline empty object field count", 0, metadata.getField("empty").value.asObject().fields.length);
      case Failure(error):
        Assertions.fail('Expected nested TOML inline tables to succeed: ${error.toString()}');
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

  static function testInvalidTomlInlineTableStructure():Void {
    var reader = new TomlReader();
    switch (reader.read('metadata = { owner = "digigun", }')) {
      case Failure(error):
        Assertions.assertEquals("invalid toml inline table code", FormatErrorCode.InvalidStructure, error.code);
      case Success(_):
        Assertions.fail("Expected malformed TOML inline table to fail.");
    }
  }

  static function testUnsupportedTomlQuotedKeys():Void {
    var reader = new TomlReader();

    switch (reader.read('"title" = "digigun"')) {
      case Failure(error):
        Assertions.assertEquals("unsupported toml quoted property key code", FormatErrorCode.UnsupportedFeature, error.code);
      case Success(_):
        Assertions.fail("Expected quoted TOML property key to fail.");
    }

    switch (reader.read('["server"]\nenabled = true')) {
      case Failure(error):
        Assertions.assertEquals("unsupported toml quoted table name code", FormatErrorCode.UnsupportedFeature, error.code);
      case Success(_):
        Assertions.fail("Expected quoted TOML table name to fail.");
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
    table.setProperty("metadata", createMetadataObject());
    table.setProperty("enabled", true);
    table.setProperty("enabled", false);

    Assertions.assertEquals("mutable toml global property", "digigun.formats", document.getGlobalProperty("title").value.asString());
    Assertions.assertEquals("mutable toml updated bool", false, table.getProperty("enabled").value.asBool());
    Assertions.assertEquals("mutable toml array size", 2, table.getProperty("ports").value.asArray().length);
    Assertions.assertEquals("mutable toml object field", true, table.getProperty("metadata").value.asObject().getField("active").value.asBool());
    Assertions.assertTrue("mutable toml remove property", table.removeProperty("enabled"));
    Assertions.assertTrue("mutable toml remove table", document.removeTable("server"));
    Assertions.assertTrue("mutable toml table removed", !document.hasTable("server"));
  }

  static function createMetadataObject():TomlObject {
    var objectValue = new TomlObject();
    objectValue.setField("owner", "digigun");
    objectValue.setField("active", true);
    return objectValue;
  }
}
