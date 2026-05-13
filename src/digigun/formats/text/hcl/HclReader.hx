package digigun.formats.text.hcl;

import digigun.formats.FormatError;
import digigun.formats.FormatErrorCode;
import digigun.formats.FormatReader;
import digigun.formats.FormatResult;
import digigun.formats.internal.TextFormatTools;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import StringTools;

/**
 * Parses a supported native-syntax subset of HCL2 into an `HclDocument`.
 */
class HclReader implements FormatReader<String, HclDocument> {
  var source:String;
  var position:Int;
  var line:Int;
  var column:Int;

  /**
   * Creates a new HCL reader.
   */
  public function new() {}

  /**
   * Parses HCL2 text into a mutable document model.
   */
  public function read(input:String):FormatResult<HclDocument> {
    source = TextFormatTools.normalizeNewlines(input);
    position = 0;
    line = 1;
    column = 1;

    var body = parseBody(false);
    return switch (body) {
      case Failure(error):
        Failure(error);
      case Success(parsedBody):
        skipTrivia();
        if (!isAtEnd()) {
          Failure(error(FormatErrorCode.InvalidStructure, "Unexpected trailing tokens in HCL document."));
        } else {
          Success(new HclDocument(parsedBody));
        }
    };
  }

  function parseBody(untilBrace:Bool):FormatResult<HclBody> {
    var body = new HclBody();

    while (true) {
      skipTrivia();

      if (untilBrace && peekChar() == "}") {
        advanceChar();
        return Success(body);
      }

      if (isAtEnd()) {
        if (untilBrace) {
          return Failure(error(FormatErrorCode.InvalidStructure, "Unterminated HCL block."));
        }
        return Success(body);
      }

      var identifier = parseIdentifier();
      switch (identifier) {
        case Failure(errorValue):
          return Failure(errorValue);
        case Success(name):
          skipTrivia();
          if (peekChar() == "=") {
            advanceChar();
            skipTrivia();
            switch (parseValue()) {
              case Failure(parseError):
                return Failure(parseError);
              case Success(value):
                body.setAttribute(name, value);
            }
            continue;
          }

          var labels = new Array<String>();
          while (true) {
            skipTrivia();
            var char = peekChar();
            if (char == "{") {
              break;
            }

            switch (parseLabel()) {
              case Failure(parseError):
                return Failure(parseError);
              case Success(label):
                labels.push(label);
            }
          }

          if (peekChar() != "{") {
            return Failure(error(FormatErrorCode.InvalidStructure, 'Expected "{" to start HCL block body.'));
          }

          advanceChar();
          switch (parseBody(true)) {
            case Failure(parseError):
              return Failure(parseError);
            case Success(blockBody):
              body.addBlock(name, labels, blockBody);
          }
      }
    }

    return Success(body);
  }

  function parseLabel():FormatResult<String> {
    skipTrivia();
    var char = peekChar();
    if (char == "\"") {
      return switch (parseString()) {
        case Failure(errorValue):
          Failure(errorValue);
        case Success(value):
          Success(value.asString());
      };
    }
    return parseIdentifier();
  }

  function parseValue():FormatResult<HclValue> {
    skipTrivia();
    var char = peekChar();

    if (char == "\"") {
      return parseString();
    }
    if (char == "[") {
      return parseArray();
    }
    if (char == "{") {
      return parseObject();
    }
    if (char == "<" && peekOffset(1) == "<") {
      return parseHeredoc();
    }
    if (isNumberStart(char)) {
      return parseNumber();
    }
    if (isIdentifierStart(char)) {
      return parseKeywordOrBareString();
    }

    return Failure(error(FormatErrorCode.InvalidStructure, 'Unexpected HCL value token "${char}".'));
  }

  function parseKeywordOrBareString():FormatResult<HclValue> {
    var identifier = parseIdentifier();
    return switch (identifier) {
      case Failure(errorValue):
        Failure(errorValue);
      case Success(value):
        switch (value) {
          case "true":
            Success(true);
          case "false":
            Success(false);
          case "null":
            Success(HclValues.nullValue());
          default:
            Failure(error(FormatErrorCode.UnsupportedFeature, 'Unsupported HCL expression "${value}". Only literals are supported in this version.'));
        }
    };
  }

  function parseNumber():FormatResult<HclValue> {
    var start = position;
    if (peekChar() == "-") {
      advanceChar();
    }
    while (isDigit(peekChar())) {
      advanceChar();
    }
    var isFloat = false;
    if (peekChar() == ".") {
      isFloat = true;
      advanceChar();
      while (isDigit(peekChar())) {
        advanceChar();
      }
    }
    if (peekChar() == "e" || peekChar() == "E") {
      isFloat = true;
      advanceChar();
      if (peekChar() == "+" || peekChar() == "-") {
        advanceChar();
      }
      while (isDigit(peekChar())) {
        advanceChar();
      }
    }

    var text = source.substr(start, position - start);
    if (isFloat) {
      var parsedFloat = Std.parseFloat(text);
      if (Math.isNaN(parsedFloat)) {
        return Failure(error(FormatErrorCode.InvalidValue, 'Unable to parse HCL float "${text}".'));
      }
      return Success(parsedFloat);
    }

    var parsedInt = Std.parseInt(text);
    if (parsedInt == null) {
      return Failure(error(FormatErrorCode.InvalidValue, 'Unable to parse HCL integer "${text}".'));
    }
    return Success(parsedInt);
  }

  function parseString():FormatResult<HclValue> {
    if (peekChar() != "\"") {
      return Failure(error(FormatErrorCode.InvalidStructure, 'Expected string literal.'));
    }
    advanceChar();
    var output = new StringBuf();

    while (!isAtEnd()) {
      var char = peekChar();
      if (char == "\"") {
        advanceChar();
        return Success(output.toString());
      }
      if (char == "\\") {
        advanceChar();
        if (isAtEnd()) {
          return Failure(error(FormatErrorCode.InvalidStructure, "Unterminated HCL string escape."));
        }
        var escaped = peekChar();
        switch (escaped) {
          case "n": output.add("\n");
          case "r": output.add("\r");
          case "t": output.add("\t");
          case "\"": output.add("\"");
          case "\\": output.add("\\");
          default: output.add(escaped);
        }
        advanceChar();
        continue;
      }
      output.add(char);
      advanceChar();
    }

    return Failure(error(FormatErrorCode.InvalidStructure, "Unterminated HCL string literal."));
  }

  function parseHeredoc():FormatResult<HclValue> {
    advanceChar();
    advanceChar();

    var trimIndent = false;
    if (peekChar() == "-") {
      trimIndent = true;
      advanceChar();
    }

    var markerResult = parseIdentifier();
    var marker = switch (markerResult) {
      case Failure(errorValue):
        return Failure(errorValue);
      case Success(value):
        value;
    };

    if (peekChar() == "\n") {
      advanceChar();
    } else if (!isAtEnd()) {
      return Failure(error(FormatErrorCode.InvalidStructure, "Expected newline after HCL heredoc marker."));
    }

    var output = new StringBuf();
    while (!isAtEnd()) {
      var lineStart = position;
      var currentLine = readLineRaw();
      var compare = trimIndent ? StringTools.ltrim(currentLine) : currentLine;
      if (compare == marker) {
        return Success(output.toString());
      }
      if (output.length > 0) {
        output.add("\n");
      }
      output.add(currentLine);
    }

    return Failure(error(FormatErrorCode.InvalidStructure, 'Unterminated HCL heredoc "${marker}".'));
  }

  function parseArray():FormatResult<HclValue> {
    advanceChar();
    var array = new HclArray();
    skipTrivia();

    while (!isAtEnd() && peekChar() != "]") {
      switch (parseValue()) {
        case Failure(errorValue):
          return Failure(errorValue);
        case Success(value):
          array.add(value);
      }

      skipTrivia();
      if (peekChar() == ",") {
        advanceChar();
        skipTrivia();
      } else if (peekChar() != "]") {
        return Failure(error(FormatErrorCode.InvalidStructure, 'Expected "," or "]" in HCL array.'));
      }
    }

    if (peekChar() != "]") {
      return Failure(error(FormatErrorCode.InvalidStructure, "Unterminated HCL array."));
    }
    advanceChar();
    return Success(array);
  }

  function parseObject():FormatResult<HclValue> {
    advanceChar();
    var object = new HclObject();
    skipTrivia();

    while (!isAtEnd() && peekChar() != "}") {
      var keyResult = parseObjectKey();
      var key = switch (keyResult) {
        case Failure(errorValue):
          return Failure(errorValue);
        case Success(value):
          value;
      };

      skipTrivia();
      if (peekChar() != "=" && peekChar() != ":") {
        return Failure(error(FormatErrorCode.InvalidStructure, 'Expected "=" or ":" in HCL object field.'));
      }
      advanceChar();
      skipTrivia();

      switch (parseValue()) {
        case Failure(errorValue):
          return Failure(errorValue);
        case Success(value):
          object.setField(key, value);
      }

      skipTrivia();
      if (peekChar() == ",") {
        advanceChar();
        skipTrivia();
      } else if (peekChar() != "}" && peekChar() != "\"" && !isIdentifierStart(peekChar())) {
        return Failure(error(FormatErrorCode.InvalidStructure, 'Expected "," or "}" in HCL object.'));
      }
    }

    if (peekChar() != "}") {
      return Failure(error(FormatErrorCode.InvalidStructure, "Unterminated HCL object."));
    }
    advanceChar();
    return Success(object);
  }

  function parseObjectKey():FormatResult<String> {
    if (peekChar() == "\"") {
      return switch (parseString()) {
        case Failure(errorValue):
          Failure(errorValue);
        case Success(value):
          Success(value.asString());
      };
    }
    return parseIdentifier();
  }

  function parseIdentifier():FormatResult<String> {
    if (!isIdentifierStart(peekChar())) {
      return Failure(error(FormatErrorCode.InvalidStructure, 'Expected HCL identifier.'));
    }

    var start = position;
    advanceChar();
    while (isIdentifierPart(peekChar())) {
      advanceChar();
    }
    return Success(source.substr(start, position - start));
  }

  function skipTrivia():Void {
    while (!isAtEnd()) {
      var char = peekChar();
      if (char == " " || char == "\t" || char == "\n" || char == "\r") {
        advanceChar();
        continue;
      }
      if (char == "#") {
        skipLineComment();
        continue;
      }
      if (char == "/" && peekOffset(1) == "/") {
        advanceChar();
        advanceChar();
        skipLineComment();
        continue;
      }
      if (char == "/" && peekOffset(1) == "*") {
        advanceChar();
        advanceChar();
        skipBlockComment();
        continue;
      }
      break;
    }
  }

  function skipLineComment():Void {
    while (!isAtEnd() && peekChar() != "\n") {
      advanceChar();
    }
  }

  function skipBlockComment():Void {
    while (!isAtEnd()) {
      if (peekChar() == "*" && peekOffset(1) == "/") {
        advanceChar();
        advanceChar();
        return;
      }
      advanceChar();
    }
  }

  function readLineRaw():String {
    var start = position;
    while (!isAtEnd() && peekChar() != "\n") {
      advanceChar();
    }
    var lineText = source.substr(start, position - start);
    if (peekChar() == "\n") {
      advanceChar();
    }
    return lineText;
  }

  inline function isAtEnd():Bool {
    return position >= source.length;
  }

  inline function peekChar():String {
    return isAtEnd() ? "" : source.charAt(position);
  }

  inline function peekOffset(offset:Int):String {
    var target = position + offset;
    return target >= source.length ? "" : source.charAt(target);
  }

  function advanceChar():Void {
    if (isAtEnd()) {
      return;
    }
    var char = source.charAt(position);
    position++;
    if (char == "\n") {
      line++;
      column = 1;
    } else {
      column++;
    }
  }

  inline function isIdentifierStart(char:String):Bool {
    if (char == "") {
      return false;
    }
    var code = char.charCodeAt(0);
    return (code >= "A".code && code <= "Z".code) || (code >= "a".code && code <= "z".code) || char == "_" ;
  }

  inline function isIdentifierPart(char:String):Bool {
    if (char == "") {
      return false;
    }
    var code = char.charCodeAt(0);
    return isIdentifierStart(char) || (code >= "0".code && code <= "9".code) || char == "-";
  }

  inline function isNumberStart(char:String):Bool {
    return char == "-" || isDigit(char);
  }

  inline function isDigit(char:String):Bool {
    if (char == "") {
      return false;
    }
    var code = char.charCodeAt(0);
    return code >= "0".code && code <= "9".code;
  }

  inline function error(code:FormatErrorCode, message:String):FormatError {
    return new FormatError(code, message, new digigun.formats.FormatLocation(line, column), HclFormat.id);
  }
}
