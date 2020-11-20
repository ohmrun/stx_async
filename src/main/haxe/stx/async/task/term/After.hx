package stx.async.task.term;

class After<R,E> extends TaskCls<R,E>{
  var inner : Seq<R,Any,E>;
  public function new(next:Task<R,E>,work:Work){
    super();
    this.inner = new Seq(next,work.latch());
  }
  override public function get_signal():Signal<Noise>{
    return this.inner.signal;
  }
  override public function get_defect():Defect<E>{
    return this.inner.defect;
  }
  override public function get_result():Null<R>{
    return this.inner.result.fst();
  }
  override public function get_status():GoalStatus{
    return this.inner.status;
  }
  override public function pursue(){
    this.inner.pursue();
  }
  override public function escape(){
    this.inner.escape();
  }
}