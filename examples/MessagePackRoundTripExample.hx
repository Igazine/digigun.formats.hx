import digigun.formats.FormatResult;
import digigun.formats.text.msgpack.MessagePackCodec;
import digigun.formats.text.msgpack.MessagePackDocument;
import digigun.formats.text.msgpack.MessagePackMap;

class MessagePackRoundTripExample {
  static function main() {
    var root = new MessagePackMap();
    root.setProperty("name", "digigun");
    root.setProperty("count", 2);
    root.setProperty("tags", ["alpha", "stable"]);

    var codec = new MessagePackCodec();
    var document = new MessagePackDocument(root);

    switch (codec.write(document)) {
      case Success(bytes):
        switch (codec.read(bytes)) {
          case Success(parsed):
            trace(parsed.getRootMap().getProperty("name").value.asString());
          case Failure(error):
            trace(error.toString());
        }
      case Failure(error):
        trace(error.toString());
    }
  }
}
