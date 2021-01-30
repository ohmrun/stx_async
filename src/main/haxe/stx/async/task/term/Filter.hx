package stx.async.task.term;

abstract class Filter<R,Ri,E> extends Delegation<Ri,Task<R,E>,E>{
  public function new(delegation:Task<R,E>,?pos:Pos){
    super(delegation,pos);
    ////__.log()(delegation);
  }
  abstract function filter(r:R):Ri;

  public inline function pursue(){
    this.delegation.pursue();
  }
  public inline function escape(){
    this.delegation.escape();
  }
  public inline function update(){
    this.delegation.update();
  }
  public function get_loaded():Bool{
    return this.delegation.get_loaded();
  }
  public function get_status():GoalStatus{
    return this.delegation.get_status();
  }
  public function get_result(){
    return filter(this.delegation.get_result());
  }
  public function get_defect(){
    return this.delegation.get_defect();
  }
  public function get_id(){
    return this.delegation.get_id();
  }
  override public function toString(){
    return this.delegation.toString();
  }
}