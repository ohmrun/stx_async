package stx.async.task.term;

abstract class Filter<R,Ri,E> extends Delegation<Ri,Task<R,E>,E>{
  public function new(delegation:Task<R,E>,?pos:Pos){
    super(delegation,pos);
    ////__.log()(delegation);
  }
  abstract function filter(r:R):Ri;

  override public inline function pursue(){
    this.delegation.pursue();
  }
  override public inline function escape(){
    this.delegation.escape();
  }
  override public inline function update(){
    this.delegation.update();
  }
  override public function get_loaded():Bool{
    return this.delegation.get_loaded();
  }
  override public function get_status():GoalStatus{
    return this.delegation.get_status();
  }
  override public function get_result(){
    return filter(this.delegation.get_result());
  }
  override public function get_defect(){
    return this.delegation.get_defect();
  }
  override public function get_id(){
    return this.delegation.get_id();
  }
  override public function toString(){
    return this.delegation.toString();
  }
}