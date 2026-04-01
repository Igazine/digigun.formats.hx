package test.ndjson;

import digigun.formats.FormatErrorCode;
import digigun.formats.ndjson.NdjsonCodec;
import digigun.formats.ndjson.NdjsonDocument;
import digigun.formats.ndjson.NdjsonReader;
import test.Assertions;
import test.FixtureTools;

class NdjsonTests {
  public static function run():Void {
    testNdjsonParsing();
    testNdjsonRoundTrip();
    testMutableNdjsonEditing();
    testInvalidNdjson();
  }

  static function testNdjsonParsing():Void {
    var reader = new NdjsonReader();
    var source = FixtureTools.text("ndjson/parse.ndjson");

    switch (reader.read(source)) {
      case Success(document):
        Assertions.assertEquals("ndjson record count", 3, document.records.length);
        Assertions.assertEquals("ndjson first object name", "digigun", Reflect.field(document.getRecord(0), "name"));
        Assertions.assertEquals("ndjson third bool", true, document.getRecord(2));
      case Failure(error):
        Assertions.fail('Expected NDJSON parse to succeed: ${error.toString()}');
    }
  }

  static function testNdjsonRoundTrip():Void {
    var document = new NdjsonDocument();
    document.addRecord({name: "digigun", count: 2});
    document.addRecord(["alpha", "beta"]);
    var codec = new NdjsonCodec();

    var serialized = switch (codec.write(document)) {
      case Success(value):
        value;
      case Failure(error):
        Assertions.fail('Expected NDJSON write to succeed: ${error.toString()}');
        "";
    };

    Assertions.assertEquals("ndjson serialized fixture", FixtureTools.text("ndjson/serialize.ndjson"), serialized);

    switch (codec.read(serialized)) {
      case Success(parsed):
        Assertions.assertEquals("ndjson round trip record count", 2, parsed.records.length);
        Assertions.assertEquals("ndjson round trip object count", 2, Reflect.field(parsed.getRecord(0), "count"));
        var arrayRecord:Array<Dynamic> = cast parsed.getRecord(1);
        Assertions.assertEquals("ndjson round trip array size", 2, arrayRecord.length);
      case Failure(error):
        Assertions.fail('Expected NDJSON round trip parse to succeed: ${error.toString()}');
    }
  }

  static function testMutableNdjsonEditing():Void {
    var document = new NdjsonDocument();
    document.addRecord({name: "digigun"});
    document.setRecord(1, {active: true});

    Assertions.assertTrue("ndjson has record 1", document.hasRecord(1));
    Reflect.setField(document.getRecord(0), "name", "igazine");
    Assertions.assertEquals("ndjson edited object field", "igazine", Reflect.field(document.getRecord(0), "name"));
    Assertions.assertTrue("ndjson remove record", document.removeRecord(1));
    Assertions.assertTrue("ndjson record removed", !document.hasRecord(1));
  }

  static function testInvalidNdjson():Void {
    var reader = new NdjsonReader();
    switch (reader.read("{bad json}")) {
      case Failure(error):
        Assertions.assertEquals("invalid ndjson code", FormatErrorCode.InvalidStructure, error.code);
      case Success(_):
        Assertions.fail("Expected malformed NDJSON to fail.");
    }
  }
}
