package stx.async.loop.term;

class Thread extends LoopCls{
  var initialized : Bool;
  public function new(){
    this.initialized = false;
    super();
  }
  override public function add(work:Work){
    __.log()('add work: $work');
    super.add(work);
  }
  function rec(){
    while(true){
      var output = reply();
      __.log()('continue? $output');
      if(!output){
        break;
      }
    }
  }
  override public function ignition(){
    if(!initialized){
      this.initialized = true;
      MainLoop.addThread(rec);
    }
  }
}