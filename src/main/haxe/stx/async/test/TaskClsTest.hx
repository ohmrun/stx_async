package stx.async.test;

class TaskClsTest extends utest.Test{
  public function test_cls(){
    var self = new TaskCls();
    same(self.status,Pending);
  }
  public function test_pure(){
    var self = Task.Pure(1);
    same(self.status,Secured);
    same(self.result,1);
    same(self.loaded,true);
  }
  public function test_fail(){
    var self = Task.Fail(["meh"]);
    same(self.status,Problem);
    same(self.defect,["meh"]);
    same(self.loaded,false);
  }
  public function testFuture(){
    var called  = false;
    var trigger = Future.trigger();
    var self    = Task.Later(trigger.asFuture());
    //__.log()(self.status.toString());
    same(self.status,Pending);
    notNull(self.signal);
    self.signal.nextTime().handle(
      (_) -> {
        called = true;
        //__.log()(self);
        same(Secured,self.status);
      }
    );
    self.pursue();
    same(false,called);
    same(self.status,Waiting);
    trigger.trigger(Task.Pure(1));
    same(true,called);
    same(Secured,self.status);
  }
}