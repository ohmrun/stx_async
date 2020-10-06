package stx.async;

using tink.CoreApi;
using stx.Nano;
using stx.Async;

import utest.*;

class Test{
  static public function main(){
    utest.UTest.run([
      //new TerminalTest()
      new SubmitTest()
    ]);
  }
}
class SubmitTest extends utest.Test{
  public function get_task(){
    return Work.lift(Task.Anon(
      (ctrl) -> {
        trace("one");
        return ctrl.fold(
          () -> Slot.Ready(
            Left(
              Task.Anon(
                (ctrl) -> {
                  trace("two");
                  return Slot.Ready(stx.pico.Either.right(__.success(Noise)));
                }
              )
            )
          ),
          () -> Slot.Ready(stx.pico.Either.right(__.failure(Noise)))
        );
      }
    ));
  }
  public function test_loop(async:utest.Async){
    var task : Work = get_task();
    Loop.instance.add(task);
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