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
    stx.Test.test(
      [
        new SubmitTest(),
        new CrunchTest(),
        new TaskClsTest(),
        new TerminalTest(),
        //new NewTerminalTest(),
        new LaterTest(),
        //new StepTest(),
        #if target.threaded
          new ThreadTest(),
        #end
        new GoalSeqTest(),
        new TaskSeqTest(),
      ],
      [TerminalTest]
    );
  }
}
class TaskSeqTest extends utest.Test{
  @Ignored
  public function test(){
    pass();
  }
}
class GoalSeqTest extends utest.Test{
  public function test(){
    var goal_seq = Goal.Seq(
      Goal.Thunk(
        () -> Secured
      ),
      Goal.Thunk(
        () -> Secured
      )
    );
    same(false,@:privateAccess goal_seq.sel);
    goal_seq.pursue();
    same(Secured,@:privateAccess goal_seq.lhs.get_status());
    goal_seq.pursue();
    same(true,@:privateAccess goal_seq.sel);
    //__.`()(goal_seq.get_status());
    same(Secured,goal_seq.get_status());
  }
}
class StepTest extends utest.Test{
  @:timeout(1000000)
  public function test(async:utest.Async){
    var step      = Loop.Step();
        step.exit = async.done.bind();
        step.add(Task.Pure(1).toWork());
    
    haxe.Timer.delay(
      async.done.bind()
      ,
      20000
    );
  }
}

