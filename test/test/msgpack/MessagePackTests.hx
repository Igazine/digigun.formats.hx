package test.msgpack;

import digigun.formats.FormatErrorCode;
import digigun.formats.msgpack.MessagePackArray;
import digigun.formats.msgpack.MessagePackCodec;
import digigun.formats.msgpack.MessagePackDocument;
import digigun.formats.msgpack.MessagePackMap;
import digigun.formats.msgpack.MessagePackReader;
import digigun.formats.msgpack.MessagePackValues;
import haxe.io.Bytes;
import test.Assertions;
import test.FixtureTools;

class MessagePackTests {
  public static function run():Void {
    testMessagePackParsing();
    testMessagePackEdgeFixture();
    testMessagePackRoundTrip();
    testNestedMessagePackStructures();
    testMessagePackNonStringMapKeys();
    testMutableMessagePackEditing();
    testInvalidMessagePack();
    testUnsupportedMessagePackIntegerRanges();
    testInvalidNestedMessagePackPayloads();
  }

  static function testMessagePackParsing():Void {
    var input = Bytes.ofHex(FixtureTools.hex("msgpack/parse.hex"));
    var reader = new MessagePackReader();

    switch (reader.read(input)) {
      case Success(document):
        var root = document.getRootMap();
        Assertions.assertEquals("msgpack root entry count", 2, root.entries.length);
        Assertions.assertEquals("msgpack parsed string", "digigun", root.getProperty("name").value.asString());
        Assertions.assertEquals("msgpack parsed int", 2, root.getProperty("count").value.asInt());
      case Failure(error):
        Assertions.fail('Expected MessagePack parse to succeed: ${error.toString()}');
    }
  }

  static function testMessagePackRoundTrip():Void {
    var root = new MessagePackMap();
    root.setProperty("name", "digigun");
    root.setProperty("count", 2);
    root.setProperty("enabled", true);
    root.setProperty("payload", Bytes.ofString("ok"));
    root.setProperty("tags", ["alpha", "beta"]);
    var document = new MessagePackDocument(root);
    var codec = new MessagePackCodec();

    var bytes = switch (codec.write(document)) {
      case Success(value):
        value;
      case Failure(error):
        Assertions.fail('Expected MessagePack write to succeed: ${error.toString()}');
        Bytes.alloc(0);
    };

    Assertions.assertEquals("msgpack serialized fixture", FixtureTools.hex("msgpack/serialize.hex"), bytes.toHex().toLowerCase());

    switch (codec.read(bytes)) {
      case Success(parsed):
        var map = parsed.getRootMap();
        Assertions.assertEquals("msgpack round trip entry count", 5, map.entries.length);
        Assertions.assertEquals("msgpack round trip string", "digigun", map.getProperty("name").value.asString());
        Assertions.assertEquals("msgpack round trip bytes", "ok", map.getProperty("payload").value.asBytes().toString());
        Assertions.assertEquals("msgpack round trip array size", 2, map.getProperty("tags").value.asArray().items.length);
      case Failure(error):
        Assertions.fail('Expected MessagePack round trip parse to succeed: ${error.toString()}');
    }
  }

  static function testMessagePackEdgeFixture():Void {
    var input = Bytes.ofHex(FixtureTools.hex("msgpack/edge.hex"));
    var reader = new MessagePackReader();

    switch (reader.read(input)) {
      case Success(document):
        var root = document.getRootMap();
        Assertions.assertEquals("msgpack edge positive fixint", 127, root.getProperty("max").value.asInt());
        Assertions.assertEquals("msgpack edge negative fixint", -1, root.getProperty("min").value.asInt());
        Assertions.assertEquals("msgpack edge bytes length", 3, root.getProperty("blob").value.asBytes().length);
        Assertions.assertEquals("msgpack edge nested name", "digigun", root.getProperty("nest").value.asMap().getProperty("name").value.asString());
      case Failure(error):
        Assertions.fail('Expected MessagePack edge fixture to succeed: ${error.toString()}');
    }
  }

  static function testMutableMessagePackEditing():Void {
    var document = new MessagePackDocument();
    var root = document.getOrCreateRootMap();
    document.setProperty("name", "digigun");
    document.setProperty("count", 2);

    var array = new MessagePackArray();
    array.add("alpha");
    array.add("beta");
    document.setProperty("tags", array);
    array.set(1, "stable");

    var nested = new MessagePackMap();
    nested.setProperty("enabled", true);
    document.setProperty("meta", nested);

    Assertions.assertTrue("msgpack has property", document.getProperty("name") != null);
    Assertions.assertEquals("msgpack mutated array item", "stable", document.getProperty("tags").value.asArray().get(1).asString());
    Assertions.assertEquals("msgpack nested bool", true, document.getProperty("meta").value.asMap().getProperty("enabled").value.asBool());
    Assertions.assertTrue("msgpack remove property", document.removeProperty("count"));
    Assertions.assertTrue("msgpack property removed", document.getProperty("count") == null);
  }

  static function testNestedMessagePackStructures():Void {
    var root = new MessagePackMap();
    var nested = new MessagePackMap();
    nested.setProperty("enabled", true);
    nested.setProperty("count", -5);
    nested.setProperty("ratio", 1.25);
    nested.setProperty("nothing", MessagePackValues.nullValue());

    var items = new MessagePackArray();
    items.add("alpha");
    items.add(nested);
    items.add(Bytes.ofHex("00ff10"));

    root.setProperty("items", items);
    root.setProperty("meta", nested);
    var codec = new MessagePackCodec();

    var bytes = switch (codec.write(new MessagePackDocument(root))) {
      case Success(value):
        value;
      case Failure(error):
        Assertions.fail('Expected nested MessagePack write to succeed: ${error.toString()}');
        Bytes.alloc(0);
    };

    switch (codec.read(bytes)) {
      case Success(document):
        var parsedItems = document.getProperty("items").value.asArray();
        Assertions.assertEquals("msgpack nested array size", 3, parsedItems.items.length);
        Assertions.assertEquals("msgpack nested map bool", true, parsedItems.get(1).asMap().getProperty("enabled").value.asBool());
        Assertions.assertEquals("msgpack nested negative int", -5, parsedItems.get(1).asMap().getProperty("count").value.asInt());
        Assertions.assertFloatEquals("msgpack nested float", 1.25, parsedItems.get(1).asMap().getProperty("ratio").value.asFloat());
        Assertions.assertTrue("msgpack nested null", parsedItems.get(1).asMap().getProperty("nothing").value.isNull());
        Assertions.assertEquals("msgpack nested bytes", "00ff10", parsedItems.get(2).asBytes().toHex().toLowerCase());
      case Failure(error):
        Assertions.fail('Expected nested MessagePack round trip to succeed: ${error.toString()}');
    }
  }

  static function testMessagePackNonStringMapKeys():Void {
    var reader = new MessagePackReader();
    switch (reader.read(Bytes.ofHex("8201a36f6e65a374776f02"))) {
      case Success(document):
        var root = document.getRootMap();
        Assertions.assertEquals("msgpack non-string key entry count", 2, root.entries.length);
        Assertions.assertEquals("msgpack non-string key int", 1, root.entries[0].key.asInt());
        Assertions.assertEquals("msgpack non-string key value", "one", root.entries[0].value.asString());
        Assertions.assertEquals("msgpack string key convenience lookup", 2, root.getProperty("two").value.asInt());
        Assertions.assertTrue("msgpack non-string key convenience miss", root.getProperty("1") == null);
      case Failure(error):
        Assertions.fail('Expected MessagePack map with non-string keys to succeed: ${error.toString()}');
    }
  }

  static function testInvalidMessagePack():Void {
    var reader = new MessagePackReader();
    var input = Bytes.ofHex("a361");

    switch (reader.read(input)) {
      case Failure(error):
        Assertions.assertEquals("invalid msgpack code", FormatErrorCode.InvalidStructure, error.code);
      case Success(_):
        Assertions.fail("Expected malformed MessagePack to fail.");
    }
  }

  static function testUnsupportedMessagePackIntegerRanges():Void {
    var reader = new MessagePackReader();

    switch (reader.read(Bytes.ofHex("ceffffffff"))) {
      case Failure(error):
        Assertions.assertEquals("unsupported msgpack uint32 range code", FormatErrorCode.UnsupportedFeature, error.code);
      case Success(_):
        Assertions.fail("Expected out-of-range MessagePack uint32 to fail.");
    }

    switch (reader.read(Bytes.ofHex("cf0000000000000001"))) {
      case Failure(error):
        Assertions.assertEquals("unsupported msgpack uint64 code", FormatErrorCode.UnsupportedFeature, error.code);
      case Success(_):
        Assertions.fail("Expected MessagePack uint64 to fail.");
    }
  }

  static function testInvalidNestedMessagePackPayloads():Void {
    var reader = new MessagePackReader();

    switch (reader.read(Bytes.ofHex("9201"))) {
      case Failure(error):
        Assertions.assertEquals("invalid msgpack truncated array code", FormatErrorCode.InvalidStructure, error.code);
      case Success(_):
        Assertions.fail("Expected truncated MessagePack array payload to fail.");
    }

    switch (reader.read(Bytes.ofHex("81a16b"))) {
      case Failure(error):
        Assertions.assertEquals("invalid msgpack truncated map value code", FormatErrorCode.InvalidStructure, error.code);
      case Success(_):
        Assertions.fail("Expected truncated MessagePack map value to fail.");
    }
  }
}
