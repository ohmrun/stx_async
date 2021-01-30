package stx.async.loop.term;

using stx.async.loop.term.Event;

function log(wildcard:Wildcard){
  return stx.async.Log.log(__).tag(__.here().toPosition().identifier());
}

class Event extends LoopCls{
  public function new(){
    ////__.log().info('EVENT LOOP');
    super();
  }
  var tick : TickDef;
  override public function add(work:Work){
    super.add(work);
  }
  function rec(){
    if(!reply() && tick!=null){
      ////__.log().info('done');
      tick.stop();
      exit();
    }
  }
  private function ignition(v:HookTag){
    if(tick == null){
      tick = MainLoop.add(rec);
    }
  }
} 