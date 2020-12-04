package stx.async.work.term;

class Canceller extends stx.async.task.term.Delegate<Any,Dynamic>{
  var canceller   : Void->Void;
  public function new(work:Work,canceller,?pos:Pos){
    super(work.toTaskApi(),pos);
    this.canceller  = canceller;
  }
  override public function escape(){
    this.delegate.escape();
    this.canceller();
  }
  override public inline function get_status(){
    return delegate.get_status();
  }
}