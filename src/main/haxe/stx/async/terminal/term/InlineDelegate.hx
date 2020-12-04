package stx.async.terminal.term;

class InlineDelegate<R,E> extends Delegate<R,E>{
  private inline function resolve(receiver:Receiver<R,E>,pos):Receiver<R,E>{
    return term.resolve(receiver,pos);
  }
  public inline function issue(res:Outcome<R,Defect<E>>,?pos:Pos):Receiver<R,E>{
    return term.issue(res,pos);
  }
  public inline function value(r:R,?pos:Pos):Receiver<R,E>{
    return term.value(r,pos);
  }
  public inline function error(err:Defect<E>,?pos:Pos):Receiver<R,E>{
    return term.error(err,pos);
  }
  public inline function later(ft:Future<Outcome<R,Defect<E>>>,?pos:Pos):Receiver<R,E>{
    return term.later(ft,pos);
  }
  public inline function lense(t:Task<R,E>,?pos:Pos):Receiver<R,E>{
    return term.lense(t,pos);
  }
  private inline function release<RR,EE>(next:Terminal<RR,EE>,?pos:Pos):Terminal<RR,EE>{
    return term.release(next,pos);
  }
  public inline function pause(n:Work,?pos:Pos):Terminal<R,E>{
    return term.pause(n,pos);
  }
  public inline function joint<RR,EE>(joiner:Outcome<RR,Defect<EE>> -> Work,?pos:Pos):Terminal<RR,EE>{
    return term.joint(joiner,pos);
  }
  public inline function inner<RR,EE>(join:Outcome<RR,Array<EE>> -> Void,?pos:Pos):Terminal<RR,EE>{
    return term.inner(join,pos);
  }
  public inline function toTerminalApi():Api<R,E>{
    return this;
  }
  public inline function toTask():Task<R,E>{
    return Task.lift(this);
  }
}
