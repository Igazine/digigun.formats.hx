package test;

using StringTools;

class FixtureTools {
  public static function text(path:String):String {
    #if sys
    var content = sys.io.File.getContent('test/fixtures/${path}');
    content = StringTools.replace(content, "\r\n", "\n");
    content = StringTools.replace(content, "\r", "\n");
    if (StringTools.endsWith(content, "\n")) {
      content = content.substr(0, content.length - 1);
    }
    return content;
    #else
    return "";
    #end
  }

  public static function hex(path:String):String {
    var content = text(path);
    return content.split("\n").join("").split(" ").join("").toLowerCase();
  }
}
