package stx.async.task.term;

class Stamp<T,E> extends TaskCls<T,E>{
  var delegate : Outcome<T,Defect<E>>;
  public inline function new(outcome:Outcome<T,Defect<E>>){
    super();
    this.loaded   = true;
    this.delegate = outcome;
    this.status   = Secured;
  }
  override public function get_defect(){
    return delegate.fold(
      (_) -> null,
      (e) -> e
    );
  }
  override public function get_result(){
    return delegate.fold(
      (r) -> r,
      (_) -> null
    );
  }
  override public function toString(){
    return 'Stamp($delegate)';
  }
}
