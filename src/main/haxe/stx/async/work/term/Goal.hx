package stx.async.work.term;

class Goal<R,E> extends stx.async.task.Delegate<R,E>{
  var delegate : GoalApi;
  public function new(delegate:stx.Async.GoalApi,?pos:Pos){
    super(pos);
    this.delegate = delegate;
  }
  override public function get_signal():tink.core.Signal<Noise>{
    return this.delegate.signal;
  }
  override public function get_defect():Defect<E>{
    return Defect.unit();
  }
  override public function get_result():Null<R>{
    return null;
  }
  override public function get_loaded(){
    return delegate.get_loaded();
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
  override public function toString(){
    var d = this.delegate.toString();
    return '*$d';
  }
  override public function get_id(){
    return this.delegate.get_id();
  }
}
