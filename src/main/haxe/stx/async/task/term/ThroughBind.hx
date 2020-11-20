package stx.async.task.term;

/**
  Like FlatMap, but the function gets more information about the inner state.
**/
abstract class ThroughBind<T,Ti,E> extends TaskCls<Ti,E>{
  var delegate : TaskApi<T,E>;
  var further  : Null<TaskApi<Ti,E>>;

  public function new(delegate:TaskApi<T,E>){
    super();
    this.delegate = delegate;
  }
  abstract function through_bind(outcome:Outcome<T,Defect<E>>):TaskApi<Ti,E>;

  override public inline function pursue(){
    //__.log()('loaded? $loaded $defect? $defect');
    if(!defect.is_defined() && !loaded){
      if(further == null){
        //__.log().debug('call delegate: ${__.definition(delegate).identifier()} ${delegate.id} ${delegate.status.toString()}');
        switch(delegate.status){
          case Applied : 
            delegate.pursue();
            this.further = through_bind(delegate.defect.is_defined().if_else(() -> __.failure(delegate.defect),() -> __.success(delegate.result)));
            this.status  = Pending;
          case Secured : 
            this.further = through_bind(delegate.defect.is_defined().if_else(() -> __.failure(delegate.defect),() -> __.success(delegate.result)));
            this.status  = Pending;
          case Problem : 
            this.defect = delegate.defect;
            this.status = Problem;
          case Waiting : 
            #if debug
            __.assert().exists(this.delegate.signal);
            #end
            this.status = Waiting;
            this.init_signal();
            this.delegate.signal.nextTime().handle(
              (_) -> this.trigger.trigger(Noise)
            );
          case Pending : 
            delegate.pursue();
            this.status = delegate.status;
          default :
        }
      }else{
        if(!further.loaded){
          switch(further.status){
            case Applied :
              further.pursue();
              this.loaded = true;
              this.status = Secured;
              this.result = further.result;
            case Secured : 
              this.loaded = true;
              this.status = Secured;
              this.result = further.result;
            case Problem : 
              this.status = Problem;
              this.defect = further.defect;
            case Waiting : 
              __.assert().exists(this.further.signal);
              this.status = Waiting;
              this.init_signal();
              this.further.signal.nextTime().handle(
                (_) -> this.trigger.trigger(Noise)
              );
            case Pending :
              further.pursue();
            case Working : 
          }
        }else{
          this.result = further.result;
          this.loaded = true;
          this.status = Secured;
        }
      }
    }
  }
  override public function toString(){
    return 'ThroughBind:$id($delegate)';
  }
}