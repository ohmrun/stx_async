package stx.async.task.term;

class FlatMap<T,Ti,E> extends TaskCls<Ti,E>{
  var deferred : TaskApi<T,E>;
  var flat_map : T -> TaskApi<Ti,E>;
  var further  : Null<TaskApi<Ti,E>>;

  public function new(deferred,flat_map){
    super();
    this.deferred = deferred;
    this.flat_map = flat_map;
  }
  override public inline function pursue(){
    if(defect == null && !loaded){
      if(further == null){
        deferred.pursue();
        switch(deferred.status){
          case Applied | Secured : 
            this.further = flat_map(deferred.result);
            this.status  = Pending;
          case Problem : 
            this.defect = deferred.defect;
            this.status = Problem;
          case Waiting : 
            __.assert().exists(this.deferred.signal);
            this.status = Waiting;
            this.init_signal();
            this.deferred.signal.nextTime().handle(
              (_) -> this.trigger.trigger(Noise)
            );
          default :
        }
      }else{
        if(!further.loaded){
          further.pursue();
          switch(further.status){
            case Applied | Secured : 
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
            case Pending | Working : 
          }
        }else{
          this.result = further.result;
          this.loaded = true;
          this.status = Secured;
        }
      }
    }
  }
}