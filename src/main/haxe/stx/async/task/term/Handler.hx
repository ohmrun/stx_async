package stx.async.task.term;

class Handler<T,E> extends TaskCls<T,E>{
  var delegate : TaskApi<T,E>;
  var handler  : Outcome<T,E> -> Void;
  var called   : Bool;
  public function new(delegate,handler){
    super();
    this.delegate = delegate;
    this.handler  = handler;
    this.called   = false;

    init_signal();
  }
  override public function pursue(){
    this.delegate.pursue();
    if(!called){
      switch(this.delegate.status){
        case Applied : 
          called = true;
          this.result = this.delegate.result;
          this.status = Secured;
          this.loaded = true;
          handler(__.success(this.result));
        case Problem : 
          called = true;
          this.defect = delegate.defect;
          handler(__.failure(delegate.defect));
          this.status = Problem;
        case Secured : 
          called = true;
          this.result = delegate.result;
          handler(__.success(delegate.result));
          this.status = Secured; 
          this.loaded = true;
        case Waiting :
          this.init_signal();
          __.assert().exists(delegate.signal);
          delegate.signal.handle(
            (_) -> this.trigger.trigger(Noise)
          );
        default : 
      }
    }
  }
}