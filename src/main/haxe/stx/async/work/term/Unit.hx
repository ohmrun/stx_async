package stx.async.work.term;

class Unit extends TaskCls<Noise,Noise>{
  override inline public function pursue(){
    this.result = Noise;
    this.loaded = true;
    this.status = Secured;
  }
}