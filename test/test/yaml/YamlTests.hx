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
    testMutableYamlEditing();
    testInvalidYaml();
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

  static function testMutableYamlEditing():Void {
    var document = new YamlDocument();
    var root = document.getOrCreateRootObject();
    root.setProperty("name", "digigun");
    root.setProperty("enabled", true);

    var server = new YamlObject();
    server.setProperty("port", 8080);
    root.setProperty("server", server);

    var tags = new YamlArray();
    tags.add("alpha");
    tags.add("beta");
    server.setProperty("tags", tags);
    tags.set(1, "stable");

    Assertions.assertEquals("mutable yaml updated array value", "stable", server.getProperty("tags").value.asArray().get(1).asString());
    Assertions.assertTrue("mutable yaml remove property", root.removeProperty("enabled"));
    Assertions.assertTrue("mutable yaml property removed", !root.hasProperty("enabled"));
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
}
