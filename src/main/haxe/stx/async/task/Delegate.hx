package stx.async.task;

abstract class Delegate<T,E> implements TaskApi<T,E> extends stx.async.goal.term.Delegate{

  abstract public function get_defect():Defect<E>;
  abstract public function get_result():Null<T>;

  override public function toString(){
    return Util.toString(this);
  }

  public function toTaskApi():TaskApi<T,E> return this;
  
  public function toWork(?pos:Pos):Work return this;
  
}