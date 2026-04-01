import digigun.formats.FormatResult;
import digigun.formats.ndjson.NdjsonCodec;

class NdjsonProcessExample {
  static function main() {
    var codec = new NdjsonCodec();
    var input = '{"name":"digigun","count":1}' + "\n" + '{"name":"igazine","count":2}';

    switch (codec.read(input)) {
      case Success(document):
        for (record in document.records) {
          Reflect.setField(record, "processed", true);
        }

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
