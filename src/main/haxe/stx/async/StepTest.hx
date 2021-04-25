package stx.async;

class StepTest extends TestCase{
  @:timeout(1000000)
  public function test(async:Async){
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

