import test.core.CoreTests;
import test.csv.CsvTests;
import test.env.EnvTests;
import test.ini.IniTests;
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
    YamlTests.run();
    trace("All tests passed.");
  }
}
