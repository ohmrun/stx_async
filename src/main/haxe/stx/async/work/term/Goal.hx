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
  public function get_defect():Defect<E>{
    return Defect.unit();
  }
  public function get_result():Null<R>{
    return null;
  }
  public function get_loaded(){
    return delegate.get_loaded();
  }
  public function get_status():GoalStatus{
    return this.delegate.get_status();
  }
  public function pursue(){
    this.delegate.pursue();
  }
  public function escape(){
    this.delegate.escape();
  }
  public function update(){
    this.delegate.update();
  }
  override public function toString(){
    var d = this.delegate.toString();
    return '*$d';
  }
  public function get_id(){
    return this.delegate.get_id();
  }
}
