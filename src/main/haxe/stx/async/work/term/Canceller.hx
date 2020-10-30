package stx.async.work.term;

class Canceller extends TaskCls<Any,Dynamic>{
  var delegate   : Work;
  var canceller  : Void->Void;
  public function new(delegate,canceller){
    super();
    this.delegate   = delegate;
    this.canceller  = canceller;
  }
  override public function get_signal():Signal<Noise>{
    return this.delegate.signal;
  }
  override public function get_defect():Array<Dynamic>{
    return this.delegate.defect;
  }
  override public function get_result():Null<Any>{
    return this.delegate.result;
  }
  override public function get_status():GoalStatus{
    return this.delegate.status;
  }
  override public function pursue(){
    this.delegate.pursue();
  }
  override public function escape(){
    this.delegate.escape();
    this.canceller();
  }
}