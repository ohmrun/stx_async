package stx.async.work.term;

class Block extends TaskCls<Noise,Noise>{
  var deferred : Void->Void;
  public function new(deferred){
    super();
    this.deferred = deferred;
  }
  override inline public function pursue(){
    this.deferred();
    this.result = Noise;
    this.loaded = true;
    this.status = Secured;
  }
}