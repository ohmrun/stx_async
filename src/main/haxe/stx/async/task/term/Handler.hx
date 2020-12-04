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
    switch(this.get_status()){
      case Problem : 
        handle(__.failure(delegate.get_defect()));
      case Pending :
        this.delegate.pursue();
      case Working : 
      case Waiting : 
        delegate.signal.handle(
          (_) -> this.trigger.trigger(Noise)
        );
      case Applied : 
        this.delegate.pursue();
        handle(__.success(this.get_result()));
      case Secured :
        handle(__.success(this.get_result()));
    }
  }
  override public function toString(){
    var id = this.delegate.toString();
    return 'Handler($id)';
  }

  override public inline function get_status(){
    return delegate.get_status();
  }
}