package stx.async.work.term;

class Delegate extends TaskCls<Any,Dynamic>{
  var delegate : WorkApi;
  public function new(delegate:WorkApi){
    super();
    this.delegate = delegate;
  }
  override public function get_signal():tink.core.Signal<Noise>{
    return this.delegate.signal;
  }
  override public function get_defect():Defect<Dynamic>{
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
  }
}