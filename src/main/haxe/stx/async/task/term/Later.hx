package stx.async.task.term;

class Later<T,E> extends TaskCls<T,E>{
  var delegate : Future<T>;
  var started  : Bool;
  public function new(delegate){
    super();
    this.delegate = delegate;
    this.started  = false;
  }
  override public function pursue(){
    if(!started){
      this.started = true;
      this.delegate.handle(
        (x) -> {
          this.result = x;
          this.status = Secured;
          this.loaded = true;
          this.trigger.trigger(Noise);
        }
      );
    }
  }
}