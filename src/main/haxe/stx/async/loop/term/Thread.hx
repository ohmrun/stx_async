package stx.async.loop.term;

using stx.async.loop.term.Thread;

function log(wildcard:Wildcard){
  return new stx.Log().tag("stx.async.loop.term.Thread");
}
class Thread extends LoopCls{
  var ignitioned    : Bool;
  var was_suspended : Bool;

  public function new(){
    this.ignitioned    = false;
    this.was_suspended = false;
    super();
  }
  override public function add(work:Work){
    //__.log()('add work: $work');
    super.add(work);
  }
  function rec(){
    while(true){
      var output = reply();
      //__.log()('continue? $output');
      if(!output){
        break;
      }
    }
  }
  override public function ignition(v:HookTag){
    //trace('thread: ignition');
    if(!ignitioned){
      this.ignitioned = true;
      sys.thread.Thread.create(rec);
    }
  }
}