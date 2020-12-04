package stx.async.task.term;

/**
  Like FlatMap, but the function gets more information about the inner state.
**/
abstract class ThroughBind<T,Ti,E> extends stx.async.task.Direct<Ti,E>{
  var delegate : TaskApi<T,E>;
  var further  : Null<TaskApi<Ti,E>>;

  public function new(delegate:TaskApi<T,E>){
    super();
    this.delegate = delegate;
  }
  abstract function through_bind(outcome:Outcome<T,Defect<E>>):TaskApi<Ti,E>;

  override public inline function pursue(){
    ////__.log()('loaded? $loaded $defect? $defect');
    if(!defect.is_defined() && !get_loaded()){
      if(further == null){
        ////__.log().debug('call delegate: ${__.definition(delegate).identifier()} ${delegate.id} ${delegate.status.toString()}');
        switch(delegate.get_status()){
          case Applied : 
            delegate.pursue();
            this.further = through_bind(delegate.get_defect().is_defined().if_else(() -> __.failure(delegate.get_defect()),() -> __.success(delegate.get_result())));
            this.status  = Pending;
          case Secured : 
            this.further = through_bind(delegate.get_defect().is_defined().if_else(() -> __.failure(delegate.get_defect()),() -> __.success(delegate.get_result())));
            this.status  = Pending;
          case Problem : 
            
            this.status = Problem;
          case Waiting : 
            #if debug
            __.assert().exists(this.delegate.signal);
            #end
            this.status = Waiting;
            this.delegate.signal.nextTime().handle(
              (_) -> this.trigger.trigger(Noise)
            );
          case Pending : 
            delegate.pursue();
            this.status = delegate.get_status();
          default :
        }
      }else{
        if(!further.get_loaded()){
          switch(further.get_status()){
            case Applied :
              further.pursue();
              this.status = Secured;
            case Secured : 
              this.status = Secured;
            case Problem : 
              this.status = Problem;
            case Waiting : 
              __.assert().exists(this.further.signal);
              this.status = Waiting;
              this.further.signal.nextTime().handle(
                (_) -> this.trigger.trigger(Noise)
              );
            case Pending : further.pursue();
            case Working : 
          }
        }else{
          this.status = Secured;
        }
      }
    }
  }
  override public function toString(){
    return 'ThroughBind:$id($delegate)';
  }
  override public function get_defect(){
    return delegate.get_defect().concat(__.option(further).map(_ -> _.get_defect()).def(Defect.unit));
  }
  override public function get_result(){
    return __.option(this.further).map(_ -> _.get_result()).defv(null);
  }
}