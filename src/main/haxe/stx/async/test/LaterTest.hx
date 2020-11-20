package stx.async.test;

class LaterTest extends utest.Test{
  public function test(){
    var task = Task.Later(Task.Pure(1));
        //__.log().close()(task.loaded);
        equals(Pending,task.status);
        task.pursue();
        equals(Secured,task.status);
        //__.log().close()(task.status);
        //__.log().close()(task.status.toString());
  }
}