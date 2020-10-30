package stx.async.test;

class ThreadTest extends utest.Test{
  public function test(){
    var thread = (@:privateAccess haxe.EntryPoint.mainThread);
    notNull(thread);
  }
}