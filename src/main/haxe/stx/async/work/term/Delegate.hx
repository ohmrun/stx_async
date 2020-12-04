package stx.async.work.term;

class Delegate extends stx.async.task.Direct<Any,Dynamic>{
  var delegate : WorkApi;
  public function new(delegate:WorkApi,?pos:Pos){
    super(delegate.pos);
    this.delegate = delegate;
    this.pos      = pos;
  }
  override public function get_signal():tink.core.Signal<Noise>{
    return this.delegate.signal;
  }
  override public function get_defect():Defect<Dynamic>{
    return this.delegate.get_defect();
  }
  override public function get_result():Null<Any>{
    return this.delegate.get_result();
  }
  override public function get_status():GoalStatus{
    return this.delegate.get_status();
  }
  override public function pursue(){
    this.delegate.pursue();
  }
  override public function escape(){
    this.delegate.escape();
  }
  override public function update(){
    this.delegate.update();
  }
}