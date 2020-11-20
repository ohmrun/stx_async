package stx.async.task.term;

class Handler<T,E> extends Delegate<T,E>{
  var handler  : Outcome<T,Defect<E>> -> Void;
  var called   : Bool;
  public function new(delegate,handler){
    super(delegate);
    this.delegate = delegate;
    this.handler  = handler;
    this.called   = false;
  }
  private function handle(outcome){
    if(!this.called){
      this.called = true;
      handler(outcome);
    }
  }
  override public function pursue(){
    switch(this.status){
      case Problem : 
        handle(__.failure(delegate.defect));
      case Pending :
        this.delegate.pursue();
      case Working : 
      case Waiting : 
        this.init_signal();
        delegate.signal.handle(
          (_) -> this.trigger.trigger(Noise)
        );
      case Applied : 
        this.delegate.pursue();
        this.delegate.status  = Secured;
        this.loaded           = true;
        handle(__.success(this.result));
      case Secured :
        this.loaded           = true;
        handle(__.success(this.result));
    }
  }
  override public function toString(){
    var id = this.delegate.toString();
    return 'Handler($id)';
  }
}