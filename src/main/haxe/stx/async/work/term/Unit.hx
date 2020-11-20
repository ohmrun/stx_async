package stx.async.work.term;

class Unit extends TaskCls<Noise,Noise>{
  public function new(){
    super();
    this.status = Secured;
    this.result = Noise;
    this.loaded = true;
  }
  override inline public function pursue(){
    
  }
}