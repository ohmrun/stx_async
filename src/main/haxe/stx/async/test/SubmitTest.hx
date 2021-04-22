package stx.async.test;

class SubmitTest extends TestCase{
  public function test(async:Async){
    var loop    = Loop.Event();
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