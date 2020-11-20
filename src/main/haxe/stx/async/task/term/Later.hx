package stx.async.task.term;

class Later<T,E> extends TaskCls<T,E>{
  var delegate  : Future<Task<T,E>>;
  var further   : Null<Task<T,E>>;
  var started   : Bool;
  public function new(delegate){
    super();
    this.delegate = delegate;
    this.started  = false;
  }
  override public inline function pursue(){
    //__.log().debug('pursue: loaded: $loaded defect $defect');
    if(!this.loaded && !defect.is_defined()){
      //__.log().debug('pursue');
      if(!this.started){
        this.started = true;
        this.delegate.handle(
          (next) -> {
            this.further = next;
          }
        );
        if(this.further == null){
          //__.log().debug('async');
          this.status = Waiting;
          init_signal();
          this.delegate.handle(
            (next) -> {
              //__.log().debug('later received');
              this.status = this.further.status;
              this.defect = this.further.defect;
              this.loaded = this.further.loaded;

              this.trigger.trigger(Noise);
            }
          );
        }else{
          //__.log().debug('sync');
          if(this.further.status == Pending){
            this.further.pursue();
          }
          this.status = this.further.status;
          this.defect = this.further.defect;
          this.loaded = this.further.loaded;
        }
      }else{
        if(this.further.status == Pending){
          this.further.pursue();
        }
        this.status = this.further.status;
        this.defect = this.further.defect;
        this.loaded = this.further.loaded;
      }
    }
  }
  override public function toString(){
    return this.further == null ? 'Later(?)' : this.further.toString();
  }
}