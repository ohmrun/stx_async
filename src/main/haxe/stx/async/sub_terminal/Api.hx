package stx.async.sub_terminal;

interface Api<R,E> extends stx.async.declared.Api{
  private function resolve(receiver:Receiver<R,E>,?pos:Pos):Receiver<R,E>;

  public function issue(res:Outcome<R,Defect<E>>,?pos:Pos):Receiver<R,E>;
  public function value(r:R,?pos:Pos):Receiver<R,E>;
  public function error(err:Defect<E>,?pos:Pos):Receiver<R,E>;
  public function later(ft:Future<Outcome<R,Defect<E>>>,?pos:Pos):Receiver<R,E>;
  public function lense(t:Task<R,E>,?pos:Pos):Receiver<R,E>;

  public function toTask():Task<R,E>;
  public function toWork(?pos:Pos):Work;
  public function toGoalApi():GoalApi;
}