package stx.async.task;

interface Api<R,E> extends GoalApi{
  public function get_defect():Defect<E>;
  public function get_result():Null<R>;
  

  public function toWork(?pos:Pos):Work;
  public function toTaskApi():TaskApi<R,E>;

  public function toString():String;
}