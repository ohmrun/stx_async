package stx.async.loop.term;

class Event extends LoopCls{
  var tick : TickDef;
  override public function add(work:Work){
    super.add(work);
    ignition();
  }
  function rec(){
    if(!reply()){
      tick.stop();
    }
  }
  override public function ignition(){
    if(tick == null){
      tick = MainLoop.add(rec);
    }
  }
}