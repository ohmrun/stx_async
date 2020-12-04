package stx.async.work.term;

class Shim implements WorkApi extends stx.async.goal.term.Delegated{
  var task : Task<Dynamic,Dynamic>;
  public function new(task:Task<Dynamic,Dynamic>,?pos:Pos){
    super(task.toGoalApi(),pos);
    this.task = task;
  }
  public function toWork(?pos:Pos):Work return Work.lift(this);
  public function toTaskApi():TaskApi<Any,Dynamic> return this;

  public inline function get_defect():Defect<Dynamic>{
    return this.task.get_defect().elide();
  }
  public inline function get_result():Null<Any>{
    return null;
  }
  override inline public function equals(that:DeclaredApi){
    return this.task.get_id() == that.get_id();
  }
  override public inline function toString(){
    return this.task.toString();
  }
}