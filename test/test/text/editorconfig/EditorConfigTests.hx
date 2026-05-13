package test.text.editorconfig;

import digigun.formats.FormatErrorCode;
import digigun.formats.text.editorconfig.EditorConfigCodec;
import digigun.formats.text.editorconfig.EditorConfigDocument;
import digigun.formats.text.editorconfig.EditorConfigReader;
import test.Assertions;
import test.FixtureTools;

class EditorConfigTests {
  public static function run():Void {
    testEditorConfigParsing();
    testEditorConfigRoundTrip();
    testEditorConfigEscapesAndEditing();
    testInvalidEditorConfigEntry();
    testInvalidEditorConfigSection();
  }

  static function testEditorConfigParsing():Void {
    var reader = new EditorConfigReader();
    var source = FixtureTools.text("text/editorconfig/parse.editorconfig");

    switch (reader.read(source)) {
      case Success(document):
        Assertions.assertTrue("editorconfig root flag", document.getRoot());
        Assertions.assertEquals("editorconfig global count", 3, document.globalProperties.length);
        Assertions.assertEquals("editorconfig section count", 1, document.sections.length);
        Assertions.assertEquals("editorconfig section name", "src/[generated].hx", document.sections[0].name);
        Assertions.assertEquals("editorconfig section property count", 2, document.sections[0].properties.length);
        Assertions.assertEquals("editorconfig section property value", "utf-8", document.sections[0].getProperty("charset").value.asString());
      case Failure(error):
        Assertions.fail('Expected EditorConfig parse to succeed: ${error.toString()}');
    }
  }

  static function testEditorConfigRoundTrip():Void {
    var document = new EditorConfigDocument();
    document.setRoot(true);
    document.setGlobalProperty("indent_style", "space");
    document.setGlobalProperty("escaped", "hello # world = test");
    var section = document.getOrCreateSection("src/[generated].hx");
    section.setProperty("charset", "utf-8");
    section.setProperty("pattern", "x;y:#");

    var codec = new EditorConfigCodec();
    var serialized = switch (codec.write(document)) {
      case Success(value):
        value;
      case Failure(error):
        Assertions.fail('Expected EditorConfig write to succeed: ${error.toString()}');
        "";
    };

    Assertions.assertEquals("editorconfig serialized fixture", FixtureTools.text("text/editorconfig/serialize.editorconfig"), serialized);

    switch (codec.read(serialized)) {
      case Success(parsed):
        Assertions.assertTrue("editorconfig round trip root", parsed.getRoot());
        Assertions.assertEquals("editorconfig round trip section count", 1, parsed.sections.length);
        Assertions.assertEquals("editorconfig round trip escaped value", "hello # world = test", parsed.getGlobalProperty("escaped").value.asString());
        Assertions.assertEquals("editorconfig round trip section glob", "src/[generated].hx", parsed.sections[0].name);
        Assertions.assertEquals("editorconfig round trip special value", "x;y:#", parsed.sections[0].getProperty("pattern").value.asString());
      case Failure(error):
        Assertions.fail('Expected EditorConfig round trip parse to succeed: ${error.toString()}');
    }
  }

  static function testEditorConfigEscapesAndEditing():Void {
    var document = new EditorConfigDocument();
    document.setRoot(true);
    document.setGlobalProperty("indent_style", "space");
    Assertions.assertTrue("editorconfig root helper", document.getRoot());
    Assertions.assertTrue("editorconfig remove root helper", document.removeRoot());
    Assertions.assertTrue("editorconfig root removed", !document.getRoot());

    var reader = new EditorConfigReader();
    switch (reader.read("path = hello\\#world\\=x\\:y\\;z\n\n[src/\\[generated\\].hx]\npattern = a\\\\b")) {
      case Success(parsed):
        Assertions.assertEquals("editorconfig escaped value", "hello#world=x:y;z", parsed.getGlobalProperty("path").value.asString());
        Assertions.assertEquals("editorconfig escaped section", "src/[generated].hx", parsed.sections[0].name);
        Assertions.assertEquals("editorconfig escaped section value", "a\\b", parsed.sections[0].getProperty("pattern").value.asString());
      case Failure(error):
        Assertions.fail('Expected escaped EditorConfig parse to succeed: ${error.toString()}');
    }
  }

  static function testInvalidEditorConfigEntry():Void {
    var reader = new EditorConfigReader();
    switch (reader.read("indent_style")) {
      case Failure(error):
        Assertions.assertEquals("editorconfig invalid entry code", FormatErrorCode.InvalidStructure, error.code);
      case Success(_):
        Assertions.fail("Expected malformed EditorConfig entry to fail.");
    }
  }

  static function testInvalidEditorConfigSection():Void {
    var reader = new EditorConfigReader();
    switch (reader.read("[]")) {
      case Failure(error):
        Assertions.assertEquals("editorconfig invalid section code", FormatErrorCode.InvalidStructure, error.code);
      case Success(_):
        Assertions.fail("Expected empty EditorConfig section name to fail.");
    }
  }
}
