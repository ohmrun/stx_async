package stx.async.task;

typedef Def<R,E> = GoalDef & {
  
  public function get_result():Null<R>;
  public function get_defect():Defect<E>;

  public function toWork(?pos:Pos):Work;
  public function toTaskApi():TaskApi<R,E>;

}