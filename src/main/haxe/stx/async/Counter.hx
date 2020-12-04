package stx.async;

class Counter{
  static private var val : Int = 0;
  static public function next(){
    return val++;
  }
}