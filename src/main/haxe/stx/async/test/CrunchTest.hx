package stx.async.test;

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