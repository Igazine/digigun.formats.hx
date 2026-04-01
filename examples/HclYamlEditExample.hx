import digigun.formats.FormatResult;
import digigun.formats.hcl.HclDocument;
import digigun.formats.yaml.YamlDocument;
import digigun.formats.yaml.YamlObject;

class HclYamlEditExample {
  static function main() {
    var hcl = new HclDocument();
    var build = hcl.body.addBlock("build");
    build.body.setAttribute("name", "base-image");
    build.body.setAttribute("sources", ["source.amazon-ebs.example"]);

    var yaml = new YamlDocument();
    var root = yaml.getOrCreateRootObject();
    root.setProperty("name", "digigun");
    root.setProperty("active", true);

    var nested = new YamlObject();
    nested.setProperty("owner", "digigun");
    root.setProperty("meta", nested);

    trace(hcl.body.blocks.length);
    trace(yaml.getRootObject().getProperty("meta").value.asObject().getProperty("owner").value.asString());
  }
}
