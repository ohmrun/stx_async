package stx.async.terminal.term;


class Delegate<R,E> implements Api<R,E> extends stx.async.task.term.Delegate<R,E>{
  var term : Terminal<R,E>;

  public function new(term:Terminal<R,E>,?pos:Pos){
    super(term.toTask(),pos);
    this.term = term;
  }
  private function resolve(receiver:Receiver<R,E>,?pos:Pos):Receiver<R,E>{
    return term.resolve(receiver,pos);
  }
  public function issue(res:Outcome<R,Defect<E>>,?pos:Pos):Receiver<R,E>{
    return term.issue(res,pos);
  }
  public function value(r:R,?pos:Pos):Receiver<R,E>{
    return term.value(r,pos);
  }
  public function error(err:Defect<E>,?pos:Pos):Receiver<R,E>{
    return term.error(err,pos);
  }
  public function later(ft:Future<Outcome<R,Defect<E>>>,?pos:Pos):Receiver<R,E>{
    return term.later(ft,pos);
  }
  public function lense(t:Task<R,E>,?pos:Pos):Receiver<R,E>{
    return term.lense(t,pos);
  }
  private function release<RR,EE>(next:Terminal<RR,EE>,?pos:Pos):Terminal<RR,EE>{
    return term.release(next,pos);
  }
  public function pause(n:Work,?pos:Pos):Terminal<R,E>{
    return term.pause(n,pos);
  }
  public function joint<RR,EE>(joiner:Outcome<RR,Defect<EE>> -> Work,?pos:Pos):Terminal<RR,EE>{
    return term.joint(joiner,pos);
  }
  public function inner<RR,EE>(join:Outcome<RR,Array<EE>> -> Void,?pos:Pos):Terminal<RR,EE>{
    return term.inner(join,pos);
  }

  public function toTerminalApi():Api<R,E>{
    return this;
  }
  public function toTask():Task<R,E>{
    return Task.lift(this);
  }
  override public inline function get_status(){
    return term.toWork().get_status();
  }
}
