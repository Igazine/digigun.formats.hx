package digigun.formats.internal;

import StringTools;

/**
 * Internal shared helpers for text-based format parsing and serialization.
 */
class TextFormatTools {
  /**
   * Normalizes CRLF and CR newlines to LF.
   */
  public static function normalizeNewlines(value:String):String {
    var normalized = StringTools.replace(value, "\r\n", "\n");
    return StringTools.replace(normalized, "\r", "\n");
  }

  /**
   * Returns whether the value is wrapped in matching single or double quotes.
   */
  public static function isQuoted(value:String):Bool {
    if (value.length < 2) {
      return false;
    }

    var first = value.charAt(0);
    var last = value.charAt(value.length - 1);
    return (first == "\"" && last == "\"") || (first == "'" && last == "'");
  }

  /**
   * Unescapes common backslash escapes in a quoted string.
   */
  public static function unescape(value:String, ?quote:String):String {
    var output = new StringBuf();
    var index = 0;

    while (index < value.length) {
      var current = value.charAt(index);
      if (current == "\\" && index + 1 < value.length) {
        var next = value.charAt(index + 1);
        switch (next) {
          case "n":
            output.add("\n");
          case "r":
            output.add("\r");
          case "t":
            output.add("\t");
          case "\\":
            output.add("\\");
          case "\"":
            output.add("\"");
          case "'":
            output.add("'");
          default:
            if (quote != null && next == quote) {
              output.add(next);
            } else {
              output.add(next);
            }
        }
        index += 2;
        continue;
      }

      output.add(current);
      index++;
    }

    return output.toString();
  }

  /**
   * Escapes a string for use inside a double-quoted literal.
   */
  public static function escapeDoubleQuoted(value:String):String {
    var escaped = StringTools.replace(value, "\\", "\\\\");
    escaped = StringTools.replace(escaped, "\"", "\\\"");
    escaped = StringTools.replace(escaped, "\n", "\\n");
    escaped = StringTools.replace(escaped, "\r", "\\r");
    escaped = StringTools.replace(escaped, "\t", "\\t");
    return escaped;
  }
}
