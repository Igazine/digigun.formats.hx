import test.core.CoreTests;
import test.image.BmpTests;
import test.image.DdsTests;
import test.image.ImageTests;
import test.image.KtxTests;
import test.image.PpmTests;
import test.image.PvrTests;
import test.image.RawTests;
import test.image.TextureBlockEncodingTests;
import test.image.TextureSupportTests;
import test.image.TgaTests;
import test.image.TiffTests;
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
    ImageTests.run();
    TextureSupportTests.run();
    TextureBlockEncodingTests.run();
    BmpTests.run();
    DdsTests.run();
    KtxTests.run();
    PpmTests.run();
    PvrTests.run();
    RawTests.run();
    TgaTests.run();
    TiffTests.run();
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
