package stx.async;

interface RuntimeApi{
  public function main():Thread;

  public function current():Thread;
  public function create(job:()->Void):Thread;
  public function runWithEventLoop(job:()->Void):Void;
  public function createWithEventLoop(job:()->Void):Thread;
  public function readMessage(block:Bool):Dynamic;
  
  public function processEvents():Void;
}
class RuntimeCls implements RuntimeApi{
  public function new(){}

  public inline function main():Thread{
    return @:privateAccess Thread.lift(haxe.EntryPoint.mainThread);
  }
  public inline function current():Thread{
    return Thread.lift(StdThread.current());
  }
  public inline function create(job:()->Void):Thread{
    trace('create');
    return Thread.lift(StdThread.create(job));
  }
  public inline function runWithEventLoop(job:()->Void):Void{
    trace('runWithEventLoop');
    StdThread.runWithEventLoop(job);
  }
  public inline function createWithEventLoop(job:()->Void):Thread{
    return Thread.lift(StdThread.createWithEventLoop(job));
  }
  public inline function readMessage(block:Bool):Dynamic{
    return sys.thread.Thread.readMessage(block);
  }
  public inline function processEvents():Void{
    @:privateAccess sys.thread.Thread.processEvents();
  }
}
@:forward abstract Runtime(RuntimeApi) from RuntimeApi{
  public static var ZERO(default,null) : Runtime = unit();
  public static function unit(){
    return new RuntimeCls();
  }
}