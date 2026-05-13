package test.yaml;

import digigun.formats.FormatErrorCode;
import digigun.formats.yaml.YamlArray;
import digigun.formats.yaml.YamlCodec;
import digigun.formats.yaml.YamlDocument;
import digigun.formats.yaml.YamlObject;
import digigun.formats.yaml.YamlReader;
import test.Assertions;
import test.FixtureTools;

class YamlTests {
  public static function run():Void {
    testYamlParsing();
    testYamlEdgeFixture();
    testYamlSampleFixture();
    testYamlRoundTrip();
    testYamlNestedFlowCollections();
    testYamlAmbiguousStringRoundTrip();
    testMutableYamlEditing();
    testInvalidYaml();
    testInvalidYamlTrailingRootContent();
    testInvalidYamlUnterminatedFlowCollection();
    testInvalidYamlMixedFlowAndBlockStructure();
    testInvalidYamlUnexpectedFlowClosingDelimiter();
    testInvalidYamlUnexpectedSequenceIndentation();
  }

  static function testYamlParsing():Void {
    var reader = new YamlReader();
    var source = FixtureTools.text("yaml/parse.yaml");

    switch (reader.read(source)) {
      case Success(document):
        var root = document.getRootObject();
        Assertions.assertEquals("yaml root property count", 3, root.properties.length);
        Assertions.assertEquals("yaml string value", "digigun", root.getProperty("name").value.asString());

        var server = root.getProperty("server").value.asObject();
        Assertions.assertEquals("yaml nested int", 8080, server.getProperty("port").value.asInt());
        Assertions.assertEquals("yaml nested array size", 2, server.getProperty("tags").value.asArray().items.length);
      case Failure(error):
        Assertions.fail('Expected YAML parse to succeed: ${error.toString()}');
    }
  }

  static function testYamlRoundTrip():Void {
    var root = new YamlObject();
    root.setProperty("name", "digigun");
    root.setProperty("enabled", true);
    var server = new YamlObject();
    server.setProperty("port", 8080);
    server.setProperty("tags", ["alpha", "beta"]);
    root.setProperty("server", server);
    var document = new YamlDocument(root);
    var codec = new YamlCodec();

    var serialized = switch (codec.write(document)) {
      case Success(value):
        value;
      case Failure(error):
        Assertions.fail('Expected YAML write to succeed: ${error.toString()}');
        "";
    };

    Assertions.assertEquals("yaml serialized fixture", FixtureTools.text("yaml/serialize.yaml"), serialized);

    switch (codec.read(serialized)) {
      case Success(parsed):
        var parsedRoot = parsed.getRootObject();
        Assertions.assertEquals("yaml round trip property count", 3, parsedRoot.properties.length);
        Assertions.assertEquals("yaml round trip nested port", 8080, parsedRoot.getProperty("server").value.asObject().getProperty("port").value.asInt());
      case Failure(error):
        Assertions.fail('Expected YAML round trip parse to succeed: ${error.toString()}');
    }
  }

  static function testYamlEdgeFixture():Void {
    var reader = new YamlReader();
    var source = FixtureTools.text("yaml/edge.yaml");

    switch (reader.read(source)) {
      case Success(document):
        var root = document.getRootObject();
        Assertions.assertEquals("yaml edge quoted title", "digigun: formats", root.getProperty("title").value.asString());
        Assertions.assertTrue("yaml edge null value", root.getProperty("empty").value.isNull());
        Assertions.assertEquals("yaml edge notes size", 2, root.getProperty("notes").value.asArray().items.length);
        Assertions.assertEquals("yaml edge flow array size", 3, root.getProperty("flow_tags").value.asArray().items.length);
        Assertions.assertEquals("yaml edge flow object bool", true, root.getProperty("flow_meta").value.asObject().getProperty("active").value.asBool());
        Assertions.assertEquals("yaml edge nested owner", "digigun", root.getProperty("meta").value.asObject().getProperty("owner").value.asString());
      case Failure(error):
        Assertions.fail('Expected YAML edge fixture to succeed: ${error.toString()}');
    }
  }

  static function testYamlSampleFixture():Void {
    var reader = new YamlReader();
    var source = FixtureTools.text("yaml/sample.yaml");

    switch (reader.read(source)) {
      case Success(document):
        var root = document.getRootObject();
        Assertions.assertEquals("yaml sample maintainers size", 2, root.getProperty("maintainers").value.asArray().items.length);
        Assertions.assertEquals("yaml sample meta version", "0.1.0", root.getProperty("meta").value.asObject().getProperty("version").value.asString());
        Assertions.assertEquals("yaml sample targets size", 3, root.getProperty("meta").value.asObject().getProperty("targets").value.asArray().items.length);
      case Failure(error):
        Assertions.fail('Expected YAML sample fixture to succeed: ${error.toString()}');
    }
  }

  static function testYamlNestedFlowCollections():Void {
    var reader = new YamlReader();
    var source = 'meta: { owner: digigun, flags: [true, "false", { stage: stable }], nested: { values: [1, 2, 3] } }';

    switch (reader.read(source)) {
      case Success(document):
        var meta = document.getProperty("meta").value.asObject();
        var flags = meta.getProperty("flags").value.asArray();
        Assertions.assertEquals("yaml nested flow flags size", 3, flags.items.length);
        Assertions.assertEquals("yaml nested flow bool item", true, flags.get(0).asBool());
        Assertions.assertEquals("yaml nested flow quoted string item", "false", flags.get(1).asString());
        Assertions.assertEquals("yaml nested flow object item", "stable", flags.get(2).asObject().getProperty("stage").value.asString());
        Assertions.assertEquals("yaml nested flow nested array value", 3, meta.getProperty("nested").value.asObject().getProperty("values").value.asArray().get(2).asInt());
      case Failure(error):
        Assertions.fail('Expected nested YAML flow collections to succeed: ${error.toString()}');
    }
  }

  static function testYamlAmbiguousStringRoundTrip():Void {
    var root = new YamlObject();
    root.setProperty("boolean_text", "true");
    root.setProperty("integer_text", "123");
    root.setProperty("null_text", "~");
    root.setProperty("flow_array_text", "[alpha]");
    root.setProperty("flow_object_text", "{ owner: digigun }");

    var codec = new YamlCodec();
    var serialized = switch (codec.write(new YamlDocument(root))) {
      case Success(value):
        value;
      case Failure(error):
        Assertions.fail('Expected YAML ambiguity write to succeed: ${error.toString()}');
        "";
    };

    switch (codec.read(serialized)) {
      case Success(document):
        Assertions.assertEquals("yaml ambiguous bool string", "true", document.getProperty("boolean_text").value.asString());
        Assertions.assertEquals("yaml ambiguous int string", "123", document.getProperty("integer_text").value.asString());
        Assertions.assertEquals("yaml ambiguous null string", "~", document.getProperty("null_text").value.asString());
        Assertions.assertEquals("yaml ambiguous flow array string", "[alpha]", document.getProperty("flow_array_text").value.asString());
        Assertions.assertEquals("yaml ambiguous flow object string", "{ owner: digigun }", document.getProperty("flow_object_text").value.asString());
      case Failure(error):
        Assertions.fail('Expected YAML ambiguity round trip to succeed: ${error.toString()}');
    }
  }

  static function testMutableYamlEditing():Void {
    var document = new YamlDocument();
    document.setProperty("name", "digigun");
    document.setProperty("enabled", true);

    var server = new YamlObject();
    server.setProperty("port", 8080);
    document.setProperty("server", server);

    var tags = new YamlArray();
    tags.add("alpha");
    tags.add("beta");
    server.setProperty("tags", tags);
    tags.set(1, "stable");

    Assertions.assertEquals("mutable yaml updated array value", "stable", server.getProperty("tags").value.asArray().get(1).asString());
    Assertions.assertTrue("mutable yaml remove property", document.removeProperty("enabled"));
    Assertions.assertTrue("mutable yaml property removed", document.getProperty("enabled") == null);
  }

  static function testInvalidYaml():Void {
    var reader = new YamlReader();
    switch (reader.read("name: test\n  bad: indent")) {
      case Failure(error):
        Assertions.assertEquals("invalid yaml code", FormatErrorCode.InvalidStructure, error.code);
      case Success(_):
        Assertions.fail("Expected malformed YAML to fail.");
    }
  }

  static function testInvalidYamlTrailingRootContent():Void {
    var reader = new YamlReader();
    switch (reader.read("- alpha\n- beta\nname: digigun")) {
      case Failure(error):
        Assertions.assertEquals("invalid yaml trailing root content code", FormatErrorCode.InvalidStructure, error.code);
      case Success(_):
        Assertions.fail("Expected trailing root YAML content to fail.");
    }
  }

  static function testInvalidYamlUnterminatedFlowCollection():Void {
    var reader = new YamlReader();
    switch (reader.read('meta: [alpha, { owner: digigun }')) {
      case Failure(error):
        Assertions.assertEquals("invalid yaml unterminated flow code", FormatErrorCode.InvalidStructure, error.code);
      case Success(_):
        Assertions.fail("Expected unterminated YAML flow collection to fail.");
    }
  }

  static function testInvalidYamlMixedFlowAndBlockStructure():Void {
    var reader = new YamlReader();
    switch (reader.read('meta: { owner: digigun\n  active: true }')) {
      case Failure(error):
        Assertions.assertEquals("invalid yaml mixed flow and block code", FormatErrorCode.InvalidStructure, error.code);
      case Success(_):
        Assertions.fail("Expected mixed flow/block YAML structure to fail.");
    }
  }

  static function testInvalidYamlUnexpectedSequenceIndentation():Void {
    var reader = new YamlReader();
    switch (reader.read("meta:\n  owner: digigun\n   - invalid")) {
      case Failure(error):
        Assertions.assertEquals("invalid yaml unexpected sequence indentation code", FormatErrorCode.InvalidStructure, error.code);
      case Success(_):
        Assertions.fail("Expected unexpectedly indented YAML sequence entry to fail.");
    }
  }

  static function testInvalidYamlUnexpectedFlowClosingDelimiter():Void {
    var reader = new YamlReader();

    switch (reader.read('meta: { owner: digigun ] }')) {
      case Failure(error):
        Assertions.assertEquals("invalid yaml unexpected closing bracket code", FormatErrorCode.InvalidStructure, error.code);
      case Success(_):
        Assertions.fail("Expected unmatched YAML flow closing bracket to fail.");
    }

    switch (reader.read('meta: [alpha, { owner: digigun } }]')) {
      case Failure(error):
        Assertions.assertEquals("invalid yaml unexpected closing brace code", FormatErrorCode.InvalidStructure, error.code);
      case Success(_):
        Assertions.fail("Expected unmatched YAML flow closing brace to fail.");
    }
  }
}
