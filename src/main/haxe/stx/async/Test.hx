package stx.async;

using tink.CoreApi;
using stx.Nano;
using stx.Async;

import haxe.unit.*;

class Test{
  static public function main(){
    __.test([
      new TerminalTest()
    ]);
  }
}
class TerminalTest extends TestCase{
  public function test(){
    var terminal  = new Terminal();
    var f         = Future.trigger();
    var a         = terminal.defer(f);

    var b         = terminal.inner(
      (oc) -> {
        f.trigger(oc.map(i -> i++));
      }
    );
    var next      = a.after(b.value(1).serve()); 
        next.crunch();
  }
}