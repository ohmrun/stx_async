package stx.async.task.term;

class FutureOutcome<T,E> extends stx.async.task.Delegate<T,E>{
  var canceller   : CallbackLink;
  var delegate    : Future<Outcome<T,Defect<E>>>;
  var response    : Outcome<T,Defect<E>>;

  var requested   : Bool;
  var delivered   : Bool;

  @:isVar var id(get,null):Int;
  public function get_id(){
    return this.id;
  }

  public function new(delegate,?pos:Pos){
    super(pos);
    this.delegate     = delegate;
    this.id           = Counter.next();
    this.requested    = false;
    this.delivered    = false;
  }
  private function handler(outcome:Outcome<T,Defect<E>>){
    //////__.log().debug(outcome);
    this.response  = outcome;
    this.delivered = true;

    this.trigger.trigger(Noise);
  }
  public function pursue(){
    //////__.log().debug('pursue: ${status.toString()} $requested $delivered');
    if(!requested){
      //////__.log().debug("requested");
      this.requested = true;
      this.canceller = this.delegate.handle(handler);
    }
  }
  public function escape(){
    if(canceller!=null){
      canceller.cancel();
    }
  }
  public function update(){
    
  }
  inline public function get_loaded(){
    return delivered;
  }
  public function get_status(){
    return requested ? delivered ? Secured : Waiting : Pending;
  }
  public function get_result(){
    return __.option(this.response).flat_map(
      _ -> _.value()
    ).defv(null);
  }
  public function get_defect(){
    return __.option(this.response).flat_map(
      _ -> _.error()
    ).def(Defect.unit);
  }

  override public function toString(){
    return Util.toString(this);
  }
}