package stx.async.task.term;

class Thunk<T,E> extends stx.async.task.Direct<T,E>{
  var delegate  : Void -> T;
  var completed : Bool; 
  public function new(delegate){
    super();
    this.delegate   = delegate;
    this.completed  = false;
  }
  inline public function pursue(){
    this.completed  = true;
    this.result     = delegate();
    this.set_status(Secured);
  }
  override public function get_loaded(){
    return completed;
  }
}