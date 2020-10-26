package stx.async;


using tink.CoreApi;
using stx.Nano;
using stx.Async;

import utest.Assert.*;
import utest.*;
import stx.async.test.*;
import stx.async.test.type.*;
import stx.async.test.type.TaskResultType;

class Test{
  static public function main(){
    utest.UTest.run([
      new SubmitTest(),
      //new CrunchTest(),
      //new TaskClsTest(),
      //new TerminalTest()
      //new SubmitTest(),
      //new LaterTest(),
      //new ThreadTest()
    ]);
  }
}
class DeferTest extends utest.Test{

}
class ThreadTest extends utest.Test{
  public function test(){
    //var thread = (@:privateAccess haxe.EntryPoint.mainThread);
    //trace(thread);
  }
}
class LaterTest extends utest.Test{
  public function test(){
    var task = Task.Later(Task.Pure(1));
        __.log().close()(task.loaded);
        equals(Pending,task.status);
        task.pursue();
        equals(Secured,task.status);
        __.log().close()(task.status);
        __.log().close()(task.status.toString());
  }
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
              async.done();
              return 1;
            }
          )
        );
  }
}
class CrunchTest extends utest.Test{
  public function test(){
    var orders = [TaskPursue,TaskResult("hello")];
    var tasks  = new ChompyTask(orders);
        tasks.pursue();
        equals(Pending,tasks.status);
        tasks.pursue();
        equals(Secured,tasks.status);
  }
}
class TerminalTest extends utest.Test{
  public function test(){
    var terminal  = new Terminal();
    var f         = Future.trigger();
        f.asFuture().handle(
          (i) -> same(__.success(2),i)
        );
    var a         = terminal.defer(f);

    var b         = terminal.inner(
      (oc) -> {
        f.trigger(__.log().close().through()(oc.map(i -> ++i)));
      }
    );
    var next      = a.after(b.value(1).serve()); 
        next.crunch();
  }
}