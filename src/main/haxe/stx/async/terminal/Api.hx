package stx.async.terminal;

interface Api<R,E> extends stx.async.declared.Api{

  //lower
  private function resolve(receiver:Receiver<R,E>,?pos:Pos):Receiver<R,E>;

  public function issue(res:Outcome<R,Defect<E>>,?pos:Pos):Receiver<R,E>;
  public function value(r:R,?pos:Pos):Receiver<R,E>;
  public function error(err:Defect<E>,?pos:Pos):Receiver<R,E>;
  public function later(ft:Future<Outcome<R,Defect<E>>>,?pos:Pos):Receiver<R,E>;
  public function lense(t:Task<R,E>,?pos:Pos):Receiver<R,E>;

  //upper
  private function release<RR,EE>(term:Terminal<RR,EE>,?pos:Pos):Terminal<RR,EE>;

  public function pause(work:stx.async.Work,?pos:Pos):Terminal<R,E>;
  public function joint<RR,EE>(joiner:Outcome<RR,Defect<EE>> -> Work,?pos:Pos):Terminal<RR,EE>;
  public function inner<RR,EE>(join:Outcome<RR,Array<EE>> -> Void,?pos:Pos):Terminal<RR,EE>;  

  
  public function toTerminalApi():Api<R,E>;

  public function toTask():Task<R,E>;
  public function toWork(?pos:Pos):Work;
  public function toGoalApi():GoalApi;
}