package stx.async.work.term;

//typedef Unit = stx.async.task.term.Unit<Dyn
class Unit extends stx.async.task.Direct<Noise,Noise>{
  public function new(){
    super();
    this.id     = Counter.next();
    this.result = Noise;
  }
  inline public function pursue(){
    
  }
  override public function get_status(){
    return Secured;
  }
  override public function get_loaded(){
    return true;
  }
}