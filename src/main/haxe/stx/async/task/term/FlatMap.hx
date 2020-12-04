package stx.async.task.term;

abstract class FlatMap<T,Ti,E> extends stx.async.task.Direct<Ti,E>{
  var deferred : TaskApi<T,E>;
  var further  : Null<TaskApi<Ti,E>>;

  public function new(deferred:TaskApi<T,E>,pos:Pos){
    super(pos);
    this.deferred = deferred;
  }
  public abstract function flat_map(t:T):TaskApi<Ti,E>;
  
  override public inline function pursue(){
    //__.log()('$deferred $further');
    if(!defect.is_defined() && !get_loaded()){
      if(further == null){
        switch(deferred.get_status()){
          case Pending           :
            deferred.pursue();
          case Applied | Secured : 
            deferred.pursue();
            this.further = flat_map(deferred.get_result());
            this.status  = Pending;
          case Problem : 
            this.status = Problem;
          case Waiting : 
            #if debug
            __.assert().exists(this.deferred.signal);
            #end
            this.status = Waiting;
            this.deferred.signal.nextTime().handle(
              (_) -> this.trigger.trigger(Noise)
            );
          default :
        }
      }else{
        if(!further.get_loaded()){
          switch(further.get_status()){
            case Applied | Secured : 
              further.pursue();
              this.set_status(Secured);
            case Problem : 
              this.set_status(Problem);
            case Waiting : 
              __.assert().exists(this.further.signal);
              this.set_status(Waiting);
              this.further.signal.nextTime().handle(
                (_) -> this.trigger.trigger(Noise)
              );
            case Pending  :
              further.pursue();
            case Working  : 
          }
        }else{
          this.set_status(Secured);
        }
      }
    }
  }
  override public function update(){
    this.deferred.update();
    if(__.option(this.further).is_defined()){
      this.further.update();
    }
  }
  override public function toString(){
    return 'FlatMap($deferred -> $further)';
  }
  override public function get_defect(){
    return deferred.get_defect().concat(__.option(further).map(_ -> _.get_defect()).def(Defect.unit));
  }
  override public function get_result(){
    return __.option(this.further).map(_ -> _.get_result()).defv(null);
  }
  override public function get_loaded(){
    return this.deferred.get_loaded().if_else(
      () -> __.option(further).map(  _ -> _.get_loaded() ).defv(false),
      ()  -> false
    );
  }
}