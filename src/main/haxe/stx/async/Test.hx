package stx.async;

using tink.CoreApi;
using stx.Nano;
using stx.Async;

import utest.*;

class Test{
  static public function main(){
    utest.UTest.run([
      new TerminalTest()
      //new SubmitTest()
    ]);
  }
}
class TerminalTest extends utest.Test{
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