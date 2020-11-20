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
        new LaterTest(),
        #if target.threaded
          new ThreadTest()
        #end
      ],
      [TerminalTest]
    );
  }
}
