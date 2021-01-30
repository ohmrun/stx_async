package stx.async.test;

class Log{
  static public function log(wildcard:Wildcard){
    return stx.Log.unit().tag("test");
  }
}