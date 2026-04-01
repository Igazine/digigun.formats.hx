import test.core.CoreTests;
import test.csv.CsvTests;
import test.env.EnvTests;
import test.hcl.HclTests;
import test.ini.IniTests;
import test.msgpack.MessagePackTests;
import test.ndjson.NdjsonTests;
import test.properties.PropertiesTests;
import test.toml.TomlTests;
import test.yaml.YamlTests;

class TestMain {
  static function main() {
    CoreTests.run();
    IniTests.run();
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
