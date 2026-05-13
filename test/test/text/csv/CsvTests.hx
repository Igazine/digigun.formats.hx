package test.text.csv;

import digigun.formats.FormatErrorCode;
import digigun.formats.text.csv.CsvCodec;
import digigun.formats.text.csv.CsvDocument;
import digigun.formats.text.csv.CsvReader;
import test.Assertions;
import test.FixtureTools;

class CsvTests {
  public static function run():Void {
    testCsvParsing();
    testCsvEdgeFixture();
    testCsvRoundTrip();
    testCsvAlternateDelimiterAndTrailingEmptyCell();
    testMutableCsvEditing();
    testInvalidCsv();
    testInvalidCsvTrailingCharactersAfterQuote();
    testInvalidCsvQuotedCellWithLeadingWhitespace();
  }

  static function testCsvParsing():Void {
    var source = FixtureTools.text("text/csv/parse.csv");
    var reader = new CsvReader();

    switch (reader.read(source)) {
      case Success(document):
        Assertions.assertEquals("csv row count", 2, document.rows.length);
        Assertions.assertEquals("csv first row cell count", 2, document.rows[0].cells.length);
        Assertions.assertEquals("csv quoted value", "hello, world", document.rows[1].cells[1].value);
      case Failure(error):
        Assertions.fail('Expected CSV parse to succeed: ${error.toString()}');
    }
  }

  static function testCsvRoundTrip():Void {
    var document = new CsvDocument();
    document.addRow(["name", "count"]);
    document.addRow(["digigun", "2"]);
    var codec = new CsvCodec();

    var serialized = switch (codec.write(document)) {
      case Success(value):
        value;
      case Failure(error):
        Assertions.fail('Expected CSV write to succeed: ${error.toString()}');
        "";
    };

    Assertions.assertEquals("csv serialized fixture", FixtureTools.text("text/csv/serialize.csv"), serialized);

    switch (codec.read(serialized)) {
      case Success(parsed):
        Assertions.assertEquals("csv round trip row count", 2, parsed.rows.length);
        Assertions.assertEquals("csv round trip value", "digigun", parsed.rows[1].cells[0].value);
      case Failure(error):
        Assertions.fail('Expected CSV round trip parse to succeed: ${error.toString()}');
    }
  }

  static function testCsvEdgeFixture():Void {
    var reader = new CsvReader();
    var source = FixtureTools.text("text/csv/edge.csv");

    switch (reader.read(source)) {
      case Success(document):
        Assertions.assertEquals("csv edge row count", 2, document.rows.length);
        Assertions.assertEquals("csv edge escaped quote", 'hello "world"', document.rows[1].cells[1].value);
        Assertions.assertTrue("csv edge multiline cell", document.rows[1].cells[2].value.indexOf("\n") >= 0);
      case Failure(error):
        Assertions.fail('Expected CSV edge fixture to succeed: ${error.toString()}');
    }
  }

  static function testMutableCsvEditing():Void {
    var document = new CsvDocument();
    var row = document.getOrCreateRow(0);
    row.setCell(0, "name");
    row.setCell(1, "value");
    var row2 = document.addRow();
    row2.addCell("digigun");
    row2.addCell("42");

    Assertions.assertTrue("mutable csv row exists", document.hasRow(1));
    Assertions.assertTrue("mutable csv cell exists", row2.hasCell(1));
    Assertions.assertEquals("mutable csv row count", 2, document.rows.length);
    Assertions.assertEquals("mutable csv cell value", "42", document.rows[1].cells[1].value);
    Assertions.assertTrue("mutable csv remove cell", row2.removeCell(1));
    Assertions.assertTrue("mutable csv remove row", document.removeRow(1));
  }

  static function testCsvAlternateDelimiterAndTrailingEmptyCell():Void {
    var reader = new CsvReader(";");
    var writer = new CsvCodec(";");
    var source = "name;value;notes;\ndigigun;42;ok;";

    switch (reader.read(source)) {
      case Success(document):
        Assertions.assertEquals("csv alternate delimiter row count", 2, document.rows.length);
        Assertions.assertEquals("csv alternate delimiter cell count", 4, document.rows[0].cells.length);
        Assertions.assertEquals("csv alternate delimiter trailing empty cell", "", document.rows[1].cells[3].value);

        switch (writer.write(document)) {
          case Success(serialized):
            Assertions.assertEquals("csv alternate delimiter round trip", source, serialized);
          case Failure(error):
            Assertions.fail('Expected alternate delimiter CSV write to succeed: ${error.toString()}');
        }
      case Failure(error):
        Assertions.fail('Expected alternate delimiter CSV parse to succeed: ${error.toString()}');
    }
  }

  static function testInvalidCsv():Void {
    var reader = new CsvReader();
    switch (reader.read('"unterminated')) {
      case Failure(error):
        Assertions.assertEquals("invalid csv code", FormatErrorCode.InvalidStructure, error.code);
      case Success(_):
        Assertions.fail("Expected malformed CSV to fail.");
    }
  }

  static function testInvalidCsvTrailingCharactersAfterQuote():Void {
    var reader = new CsvReader();
    switch (reader.read('"value"x')) {
      case Failure(error):
        Assertions.assertEquals("invalid csv trailing characters after quote code", FormatErrorCode.InvalidStructure, error.code);
      case Success(_):
        Assertions.fail("Expected trailing characters after closing CSV quote to fail.");
    }
  }

  static function testInvalidCsvQuotedCellWithLeadingWhitespace():Void {
    var reader = new CsvReader();
    switch (reader.read('a, "b"')) {
      case Failure(error):
        Assertions.assertEquals("invalid csv leading whitespace before quote code", FormatErrorCode.InvalidStructure, error.code);
      case Success(_):
        Assertions.fail("Expected CSV quote after leading whitespace to fail.");
    }
  }
}
