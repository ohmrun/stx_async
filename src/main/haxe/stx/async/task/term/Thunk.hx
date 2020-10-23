package stx.async.task.term;

class Thunk<T,E> extends TaskCls<T,E>{
  var delegate : Void -> T;
  public function new(delegate){
    super();
    this.delegate = delegate;
  }
  override inline public function pursue(){
    this.result = delegate();
    this.status = Secured;
    this.loaded = true;
  }
}