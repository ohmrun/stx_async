package stx.async.task.term;

class FutureOutcome<T,E> extends TaskCls<T,E>{
  var pos       : Pos;
  var delegate  : Future<Outcome<T,Defect<E>>>;
  var started   : Bool;
  var finished  : Bool;

  public function new(delegate,?pos){
    super();
    this.pos      = pos;
    this.delegate = delegate;
    //Gonna frontrun this because I'm getting odd errors that might be due to adding handler after delivery 05/11/2020
    //Internal changes in Tink coupled with work on haxe.EventLoop
    this.delegate.handle(handler);
    this.started  = false;
    this.finished = false;
  }
  private function handler(outcome:Outcome<T,Defect<E>>){
    init_signal();
    //__.log().debug(outcome);
    this.finished = true;
    outcome.fold(
      ok -> {
        this.result = ok;
        this.status = Secured;
        this.loaded = true;
        null;
      },
      (no:Array<E>) -> {
        this.defect = no;
        this.status = Problem;
        null;
      }
    );
    this.trigger.trigger(Noise);
  }
  override public function pursue(){
    //__.log().debug('pursue: ${status.toString()} $started $finished');
    if(!started){
      //__.log().debug("started");
      this.started = true;
      this.status  = Working;
      this.delegate.handle(handler);
    }else{
      if(this.status == Working){
        //__.log().debug('working');
        this.status = Waiting;
      }
    }
  }
  override public function toString(){
    return 'FutureOutcome:$id($started $finished ${status.toString()}) ${pos.toPosition()}';
  }
}