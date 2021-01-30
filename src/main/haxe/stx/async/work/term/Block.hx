package stx.async.work.term;

class Block extends stx.async.task.Direct<Noise,Noise>{
  var done     : Bool;
  var deferred : Void->Void;

  public function new(deferred){
    super();
    this.deferred = deferred;
  }
  inline public function pursue(){
    this.deferred();
    this.result = Noise;
    this.done   = true;
  }
  override public function get_loaded(){
    return done;
  }
  override public function get_status(){
    return done ? Secured : Applied;
  }
}