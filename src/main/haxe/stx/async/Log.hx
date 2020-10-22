package stx.async;

class Log{
  static public function log(wildcard:Wildcard):stx.Log{
    return new stx.Log().tag("stx.async");
  }
}