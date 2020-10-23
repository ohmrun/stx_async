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
    __.log().close().debug('pursue: loaded: $loaded defect $defect');
    if(!this.loaded && defect==null){
      __.log().close().debug('pursue');
      if(!this.started){
        this.started = true;
        this.delegate.handle(
          (next) -> {
            this.further = next;
          }
        );
        if(this.further == null){
          this.status = Waiting;
          init_signal();
          this.delegate.handle(
            (next) -> {
              __.log().debug('later received');
              this.trigger.trigger(Noise);
            }
          );
        }else{
          this.further.pursue();
          this.status = this.further.status;
          this.defect = this.further.defect;
          this.loaded = this.further.loaded;
        }
      }else{
        this.further.pursue();
        this.status = this.further.status;
        this.defect = this.further.defect;
        this.loaded = this.further.loaded;
      }
    }
  }
  public function toString(){
    return this.further == null ? '?' : this.further.toString();
  }
}