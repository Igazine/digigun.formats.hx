package test.hcl;

import digigun.formats.FormatErrorCode;
import digigun.formats.hcl.HclArray;
import digigun.formats.hcl.HclCodec;
import digigun.formats.hcl.HclDocument;
import digigun.formats.hcl.HclObject;
import digigun.formats.hcl.HclReader;
import test.Assertions;
import test.FixtureTools;

class HclTests {
  public static function run():Void {
    testHclParsing();
    testHclEdgeFixture();
    testHclSampleFixture();
    testHclRoundTrip();
    testMutableHclEditing();
    testInvalidHcl();
  }

  static function testHclParsing():Void {
    var reader = new HclReader();
    var source = FixtureTools.text("hcl/parse.hcl");

    switch (reader.read(source)) {
      case Success(document):
        Assertions.assertEquals("hcl block count", 2, document.body.blocks.length);
        var sourceBlock = document.body.getBlock("source", ["amazon-ebs", "example"]);
        Assertions.assertEquals("hcl source ami", "example-ami", sourceBlock.body.getAttribute("ami_name").value.asString());
        Assertions.assertEquals("hcl source tags size", 2, sourceBlock.body.getAttribute("tags").value.asArray().items.length);

        var buildBlock = document.body.getBlock("build");
        Assertions.assertTrue("hcl heredoc contains second line", buildBlock.body.getAttribute("description").value.asString().indexOf("Over two lines.") >= 0);
      case Failure(error):
        Assertions.fail('Expected HCL parse to succeed: ${error.toString()}');
    }
  }

  static function testHclRoundTrip():Void {
    var document = new HclDocument();
    var sourceBlock = document.addBlock("source", ["amazon-ebs", "example"]);
    sourceBlock.body.setAttribute("ami_name", "example-ami");
    sourceBlock.body.setAttribute("instance_count", 2);
    var objectValue = new HclObject();
    objectValue.setField("owner", "digigun");
    sourceBlock.body.setAttribute("metadata", objectValue);

    var buildBlock = document.addBlock("build");
    buildBlock.body.setAttribute("sources", ["source.amazon-ebs.example"]);
    var codec = new HclCodec();

    var serialized = switch (codec.write(document)) {
      case Success(value):
        value;
      case Failure(error):
        Assertions.fail('Expected HCL write to succeed: ${error.toString()}');
        "";
    };

    Assertions.assertEquals("hcl serialized fixture", FixtureTools.text("hcl/serialize.hcl"), serialized);

    switch (codec.read(serialized)) {
      case Success(parsed):
        var parsedSource = parsed.body.getBlock("source", ["amazon-ebs", "example"]);
        Assertions.assertEquals("hcl round trip integer", 2, parsedSource.body.getAttribute("instance_count").value.asInt());
        Assertions.assertEquals("hcl round trip object field", "digigun", parsedSource.body.getAttribute("metadata").value.asObject().getField("owner").value.asString());
      case Failure(error):
        Assertions.fail('Expected HCL round trip parse to succeed: ${error.toString()}');
    }
  }

  static function testHclEdgeFixture():Void {
    var reader = new HclReader();
    var source = FixtureTools.text("hcl/edge.hcl");

    switch (reader.read(source)) {
      case Success(document):
        var variableBlock = document.body.getBlock("variable", ["image_name"]);
        Assertions.assertEquals("hcl edge default", "digigun-base", variableBlock.body.getAttribute("default").value.asString());
        Assertions.assertTrue("hcl edge heredoc contains line two", variableBlock.body.getAttribute("description").value.asString().indexOf("line two") >= 0);
        Assertions.assertEquals("hcl edge tags size", 2, variableBlock.body.getAttribute("tags").value.asArray().items.length);
        Assertions.assertEquals("hcl edge object bool", true, variableBlock.body.getAttribute("metadata").value.asObject().getField("active").value.asBool());
      case Failure(error):
        Assertions.fail('Expected HCL edge fixture to succeed: ${error.toString()}');
    }
  }

  static function testHclSampleFixture():Void {
    var reader = new HclReader();
    var source = FixtureTools.text("hcl/sample.hcl");

    switch (reader.read(source)) {
      case Success(document):
        var packerBlock = document.body.getBlock("packer");
        Assertions.assertEquals("hcl sample required version", ">= 1.10.0", packerBlock.body.getAttribute("required_version").value.asString());
        var sourceBlock = document.body.getBlock("source", ["amazon-ebs", "base"]);
        Assertions.assertEquals("hcl sample instance type", "t3.micro", sourceBlock.body.getAttribute("instance_type").value.asString());
        Assertions.assertEquals("hcl sample object field", "formats", sourceBlock.body.getAttribute("tags").value.asObject().getField("Project").value.asString());
      case Failure(error):
        Assertions.fail('Expected HCL sample fixture to succeed: ${error.toString()}');
    }
  }

  static function testMutableHclEditing():Void {
    var document = new HclDocument();
    document.setAttribute("packer_required", true);
    var buildBlock = document.getOrCreateBlock("build");
    buildBlock.body.setAttribute("name", "base-image");
    buildBlock.body.setAttribute("sources", ["source.amazon-ebs.example"]);

    var shellBlock = buildBlock.body.addBlock("provisioner", ["shell"]);
    shellBlock.body.setAttribute("inline", ["echo hello", "echo world"]);
    shellBlock.body.setAttribute("retries", 2);
    shellBlock.body.setAttribute("retries", 3);

    Assertions.assertTrue("mutable hcl root attribute exists", document.getAttribute("packer_required") != null);
    Assertions.assertEquals("mutable hcl updated attribute", 3, shellBlock.body.getAttribute("retries").value.asInt());
    Assertions.assertTrue("mutable hcl remove attribute", shellBlock.body.removeAttribute("retries"));
    Assertions.assertTrue("mutable hcl remove block", buildBlock.body.removeBlock("provisioner", ["shell"]));
  }

  static function testInvalidHcl():Void {
    var reader = new HclReader();
    switch (reader.read("name = foo")) {
      case Failure(error):
        Assertions.assertEquals("invalid hcl code", FormatErrorCode.UnsupportedFeature, error.code);
      case Success(_):
        Assertions.fail("Expected unsupported HCL expression to fail.");
    }
  }
}
