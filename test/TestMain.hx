import test.core.CoreTests;
import test.text.editorconfig.EditorConfigTests;
import test.text.csv.CsvTests;
import test.text.env.EnvTests;
import test.text.hcl.HclTests;
import test.text.ini.IniTests;
import test.text.msgpack.MessagePackTests;
import test.text.ndjson.NdjsonTests;
import test.text.properties.PropertiesTests;
import test.text.toml.TomlTests;
import test.text.yaml.YamlTests;

class TestMain {
  static function main() {
    CoreTests.run();
    IniTests.run();
    EditorConfigTests.run();
    TomlTests.run();
    CsvTests.run();
    PropertiesTests.run();
    EnvTests.run();
    HclTests.run();
    YamlTests.run();
    MessagePackTests.run();
    NdjsonTests.run();
    trace("All tests passed.");
  }
}
