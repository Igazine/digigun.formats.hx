package test;

class Assertions {
  public static function assertTrue(label:String, value:Bool):Void {
    if (!value) {
      fail('Assertion failed: ${label}');
    }
  }

  public static function assertEquals<T>(label:String, expected:T, actual:T):Void {
    if (expected != actual) {
      fail('${label}: expected ${expected}, got ${actual}');
    }
  }

  public static function assertFloatEquals(label:String, expected:Float, actual:Float):Void {
    if (Math.abs(expected - actual) > 0.000001) {
      fail('${label}: expected ${expected}, got ${actual}');
    }
  }

  public static function fail(message:String):Void {
    throw message;
  }
}
