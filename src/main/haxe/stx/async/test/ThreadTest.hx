package stx.async.test;

class ThreadTest extends TestCase{
  public function test(){
    var thread = (@:privateAccess haxe.EntryPoint.mainThread);
    exists(thread);
  }
}