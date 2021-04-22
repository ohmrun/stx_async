package stx.async.test;

class CrunchTest extends TestCase{
  public function test(){
    var orders = [TaskPursue,TaskResult("hello")];
    var tasks  = new ChompyTask(orders);
        tasks.pursue();
        equals(Pending,tasks.get_status());
        tasks.pursue();
        equals(Secured,tasks.get_status());
  }
}