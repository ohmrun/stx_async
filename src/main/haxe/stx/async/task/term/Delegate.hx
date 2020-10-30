package stx.async.task.term;

class Delegate<R,E> extends TaskCls<R,E>{
  public var delegate(default,null):Task<R,E>;
  public function new(delegate){
    super();
    this.delegate   = delegate;
  }
  override public function get_signal():Signal<Noise>{
    return this.delegate.signal;
  }
  override public function get_defect():Defect<E>{
    return this.delegate.defect;
  }
  override public function get_result():Null<R>{
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