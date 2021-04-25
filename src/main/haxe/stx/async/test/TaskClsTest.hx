package stx.async.test;

class TaskClsTest extends TestCase{
  public function test_pure(){
    var self = Task.Pure(1);
    same(self.get_status(),Secured);
    same(self.get_result(),1);
    same(self.get_loaded(),true);
  }
  public function test_fail(){
    var self = Task.Fail(["meh"]);
    same(self.get_status(),Problem);
    same(self.get_defect(),["meh"]);
    same(self.get_loaded(),false);
  }
  public function testFuture(){
    var called  = false;
    var trigger = Future.trigger();
    var self    = Task.Later(trigger.asFuture());
    //////__.log()(self.status.toString());
    same(self.get_status(),Pending);
    exists(self.signal);
    self.signal.nextTime().handle(
      (_) -> {
        called = true;     //////__.log()(self);
        same(Secured,self.get_status());
      }
    );
    self.pursue();
    same(false,called);
    same(self.get_status(),Waiting);
    trigger.trigger(Task.Pure(1));
    same(true,called);
    same(Secured,self.get_status());
  }
}