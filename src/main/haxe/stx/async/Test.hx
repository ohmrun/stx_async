package stx.async;

using tink.CoreApi;
using stx.Nano;
using stx.Async;
using stx.Fn;

import utest.Assert.*;
import utest.*;
import stx.async.test.*;
import stx.async.test.type.*;
import stx.async.test.type.TaskResultType;

class Test{
  static public function main(){
    var data = [
      new SubmitTest(),
      new CrunchTest(),
      new TaskClsTest(),
      new TerminalTest(),
      new LaterTest(),
      new ThreadTest()
    ];
    
    var poke = data.filter(
      __.arrd([TaskClsTest]).map(__.that().iz)
        .lfold1(__.that().or)
        .defv(__.that().never())
        .check()
    );
    utest.UTest.run(#if poke poke #else data #end);
  }
}
class DeferTest extends utest.Test{

}
class SubmitTest extends utest.Test{
  public function test(async:utest.Async){
    var loop    = Loop.Thread();
    var trigger = Future.trigger();
    var next = Task.Later(trigger.asFuture());
    var task = Task.Pure("hello");
        loop.add(task.toWork().seq(next.toWork()));
        trigger.trigger(
          Task.Thunk(
            () -> {
              pass();
              async.done();
              return 1;
            }
          )
        );
  }
}