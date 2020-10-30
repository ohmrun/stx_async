package stx.async.test;

class TerminalTest extends utest.Test{
  public function test(){
    var terminal  = new Terminal();
    var f         = Future.trigger();
        f.asFuture().handle(
          (i) -> same(__.success(2),i)
        );
    var a         = terminal.later(f);

    var b         = terminal.inner(
      (oc) -> {
        __.log()('trigger: $oc');
        f.trigger(__.log().close().through()(oc.map(i -> ++i)));
      }
    );
    var next      = a.after(b.value(1).serve()); 
        next.crunch();
  }
}