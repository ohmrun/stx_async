package stx.async.task.term;

class FlatMap<T,Ti,E> extends TaskCls<Ti,E>{
  var deferred : TaskApi<T,E>;
  var flat_map : T -> TaskApi<Ti,E>;
  var further  : Null<TaskApi<Ti,E>>;

  public function new(deferred:TaskApi<T,E>,flat_map:T->TaskApi<Ti,E>){
    super();
    this.deferred = deferred;
    this.flat_map = flat_map;
  }
  override public inline function pursue(){
    if(!defect.is_defined() && !loaded){
      if(further == null){
        switch(deferred.status){
          case Pending           :
            deferred.pursue();
          case Applied | Secured : 
            deferred.pursue();
            this.further = flat_map(deferred.result);
            this.status  = Pending;
          case Problem : 
            this.defect = deferred.defect;
            this.status = Problem;
          case Waiting : 
            #if debug
            __.assert().exists(this.deferred.signal);
            #end
            this.status = Waiting;
            this.init_signal();
            this.deferred.signal.nextTime().handle(
              (_) -> this.trigger.trigger(Noise)
            );
          default :
        }
      }else{
        if(!further.loaded){
          switch(further.status){
            case Applied | Secured : 
              further.pursue();
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
            case Pending  :
              further.pursue();
            case Working  : 
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
    return 'FlatMap($deferred -> $further)';
  }
}