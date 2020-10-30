package stx.async.loop.term;

class Event extends LoopCls{
  var tick : TickDef;
  override public function add(work:Work){
    super.add(work);
  }
  function rec(){
    if(!reply() && tick!=null){
      tick.stop();
    }
  }
  override private function ignition(v:HookTag){
    if(tick == null){
      tick = MainLoop.add(rec);
    }
  }
}