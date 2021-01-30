package stx.async.task;

abstract class Direct<T,E> implements TaskApi<T,E> extends stx.async.goal.term.Direct{
  
  @:isVar public var defect(get,set):Defect<E>;
  public function get_defect():Defect<E>{
    return this.defect == null ? this.defect = Defect.unit() : this.defect;
  }
  public function set_defect(v:Defect<E>):Defect<E>{
    return this.defect = v;
  }

  @:isVar public var result(get,set):Null<T>;
  public function get_result():Null<T>{
    return this.result;
  }
  public function set_result(v:Null<T>):Null<T>{
    return this.result = v;
  }
  public function escape():Void{
  
  }
  public function update():Void{
    
  }
  public override function toGoalApi():GoalApi{
    return this;
  }
  public function toWork(?pos:Pos):Work{
    return this;
  }
  public function toTaskApi():TaskApi<T,E>{
    return this;
  }
  public function toString(){
    return Util.toString(this);
  } 
}