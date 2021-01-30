package stx.async.task.term;

class Later<T,E> extends stx.async.task.Direct<T,E>{
  var delegate  : Future<Task<T,E>>;
  var further   : Task<T,E>;
  var started   : Bool;

  public function new(delegate){
    super();
    this.delegate = delegate;
    this.started  = false;
  }
  public inline function pursue(){
    //////__.log().debug('pursue: loaded: $loaded defect $defect');
    if(!this.get_loaded() && !defect.is_defined()){
      //////__.log().debug('pursue');
      if(!this.started){
        this.started = true;
        this.delegate.handle(
          (next) -> {
            this.further = next;
          }
        );
        if(this.further == null){
          //////__.log().debug('async');
          this.delegate.handle(
            (next) -> {
              //////__.log().debug('later received');
              this.trigger.trigger(Noise);
            }
          );
        }else{
          //////__.log().debug('sync');
          if(this.further.get_status() == Pending){
            this.further.pursue();
          }
        }
      }else{
        if(this.further.get_status() == Pending){
          this.further.pursue();
        }
        this.set_status(this.further.get_status());
      }
    }
  }
  override public function toString(){
    var inner = this.further == null ? '?' : this.further.toString();
    return 'Later($inner)';
  }

  override public function get_defect(){
    return __.option(further).map(_ -> _.get_defect()).def(Defect.unit);
  }
  override public function get_result(){
    return __.option(this.further).map(_ -> _.get_result()).defv(null);
  }
  override public function get_status(){
    return started ? __.option(this.further).map(_ -> _.get_status()).defv(Waiting) : Pending;
  }
  override public function get_loaded(){
    return __.option(this.further).map(_ -> _.get_loaded()).defv(false);
  }
}