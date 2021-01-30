package stx.async.task.term;

abstract class FlatMap<T,Ti,E> extends stx.async.task.Direct<Ti,E>{
  var delegate : TaskApi<T,E>;
  var further  : Null<TaskApi<Ti,E>>;

  public function new(delegate:TaskApi<T,E>,pos:Pos){
    super(pos);
    this.delegate = delegate;
  }
  public abstract function flat_map(t:T):TaskApi<Ti,E>;
  
  public inline function pursue(){
    ////__.log()('$delegate $further');
    if(!defect.is_defined() && !get_loaded()){
      if(further == null){
        switch(delegate.get_status()){
          case Pending           : delegate.pursue();
          case Applied : 
            delegate.pursue();
            this.further = flat_map(delegate.get_result());
            switch(this.further.get_status()){
              case Problem : set_status(Problem);
              case Applied : 
                this.further.pursue();
                this.set_status(Secured);
              case Pending : set_status(Pending);
              case Working : set_status(Working);
              case Waiting : 
                this.further.signal.nextTime().handle(this.trigger.trigger);
                set_status(Waiting);
              case Secured : set_status(Secured);
            }
          case Secured : 
            this.further = flat_map(delegate.get_result());
            this.set_status(Pending);
          case Problem : 
            this.set_status(Problem);
          case Waiting : 
            #if debug
            __.assert().exists(this.delegate.signal);
            #end
            this.set_status(Waiting);
            this.delegate.signal.nextTime().handle(
              (_) -> this.trigger.trigger(Noise)
            );
          default :
        }
      }else{
        if(!further.get_loaded()){
          switch(further.get_status()){
            case Problem : 
              this.set_status(Problem);
            case Applied : 
              further.pursue();
              this.set_status(Secured);
            case Pending  :
              further.pursue();
            case Working  : 
            case Waiting : 
              this.set_status(Waiting);
              this.bubble(further);
            case Secured  :
              this.set_status(Secured);
          }
        }else{
          this.set_status(Secured);
        }
      }
    }
  }
  override public function update(){
    this.delegate.update();
    if(__.option(this.further).is_defined()){
      this.further.update();
    }
  }
  override public function toString(){
    return 'FlatMap($delegate -> $further)';
  }
  override public function get_defect(){
    return delegate.get_defect().concat(__.option(further).map(_ -> _.get_defect()).def(Defect.unit));
  }
  override public function get_result(){
    return __.option(this.further).map(_ -> _.get_result()).defv(null);
  }
  override public function get_loaded(){
    return this.delegate.get_loaded().if_else(
      () -> __.option(further).map(  _ -> _.get_loaded() ).defv(false),
      ()  -> false
    );
  }
}