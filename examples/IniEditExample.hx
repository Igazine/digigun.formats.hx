import digigun.formats.FormatResult;
import digigun.formats.ini.IniCodec;

class IniEditExample {
  static function main() {
    var codec = new IniCodec();
    var source = "[app]\nname = digigun\nenabled = true";

    switch (codec.read(source)) {
      case Success(document):
        var app = document.getOrCreateSection("app");
        app.setProperty("enabled", false);
        app.setProperty("retries", 3);

        switch (codec.write(document)) {
          case Success(output):
            trace(output);
          case Failure(error):
            trace(error.toString());
        }
      case Failure(error):
        trace(error.toString());
    }
  }
}
