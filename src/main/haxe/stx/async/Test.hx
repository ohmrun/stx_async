package stx.async;

using tink.CoreApi;
using stx.Nano;
using stx.Async;
using stx.Fn;

using stx.unit.Test;

import stx.async.test.*;
import stx.async.test.type.*;
import stx.async.test.type.TaskResultType;

class Test{
  static public function main(){
    __.unit(
      [
        // new SubmitTest(),
        // new CrunchTest(),
        // new TaskClsTest(),
        // new TerminalTest(),
        // new NewTerminalTest(),
        // new LaterTest(),
        // //new StepTest(),
        // #if target.threaded
        //   new ThreadTest(),
        // #end
        // new GoalSeqTest(),
        // new TaskSeqTest(),
      ],
      []
    );
  }
}