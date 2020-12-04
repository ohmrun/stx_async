package stx.async.task.term;

class Seq<T,Ti,E> extends stx.async.goal.term.Seq implements stx.async.task.Api<Couple<T,Ti>,E>{
  var lhs_task : Task<T,E>;
  var rhs_task : Task<Ti,E>;

  public function new(lhs:TaskApi<T,E>,rhs:TaskApi<Ti,E>,?pos:Pos){
    super(lhs,rhs,pos);
    this.lhs_task = lhs;
    this.rhs_task = rhs;
  }
  override public function toString(){
    var name = this.identifier().name;
    var self_status = this.status == null ? '<auto>' : "";
    return 'task.$name:${get_id()}[$self_status${this.get_status().toString()}]($sel of $lhs ==> $rhs)';
  }
  public function get_defect(){
    return this.lhs_task.get_defect().concat(this.rhs_task.get_defect());
  }
  public function get_result():Null<Couple<T,Ti>>{
    return __.couple(this.lhs_task.get_result(),this.rhs_task.get_result());
  }
  public function toWork(?pos:Pos):Work{
    return this;
  }
  public function toTaskApi():TaskApi<Couple<T,Ti>,E>{
    return this;
  }
}