package stx.async.task.term;

class FutureOutcome<T,E> extends TaskCls<T,E>{
  var delegate : Future<Outcome<T,E>>;
  var started  : Bool;

  public function new(delegate){
    super();
    __.assert().exists(delegate);
    this.delegate = delegate;
    this.started  = false;
  }
  override public function pursue(){
    if(!started){
      init_signal();
      this.started = true;
      this.delegate.handle(
        (oc) -> {
          oc.fold(
            ok -> {
              this.result = ok;
              this.status = Secured;
              this.loaded = true;
              null;
            },
            (no:E) -> {
              this.defect = no;
              this.status = Problem;
              null;
            }
          );
          this.trigger.trigger(Noise);
        }
      );
    }
  }
}