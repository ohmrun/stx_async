package stx.async.task.term;

class At<R,E> extends Delegate<R,E>{
  public function new(delegate,?pos:Pos){
    super(delegate);
    this.pos = pos;
  }
  public inline function get_status(){
    return delegate.get_status();
  }
  override public inline function get_id(){
    return delegate.get_id();
  }
}