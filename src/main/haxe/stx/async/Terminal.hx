package stx.async;

interface TerminalApi<R,E>{  
  public function issue(res:Outcome<R,Defect<E>>):Receiver<R,E>;
  public function value(r:R):Receiver<R,E>;
  public function error(err:Defect<E>):Receiver<R,E>;

  public function later(ft:Future<Outcome<R,Defect<E>>>):Receiver<R,E>;
  public function lense(t:Task<R,E>):Receiver<R,E>;
  public function pause(n:Work):Terminal<R,E>;

  public function inner<RR,EE>(join:Outcome<RR,Array<EE>> -> Void):Terminal<RR,EE>;
  

  public function toTerminalApi():TerminalApi<R,E>;
}
@:allow(stx) class Terminal<R,E> implements TerminalApi<R,E>{
  static public var ZERO = new Terminal();

  private function new(){}
  public function issue(res:Outcome<R,Defect<E>>):Receiver<R,E>                return res.fold(value,error);
  public function value(r:R):Receiver<R,E>                                    return Receiver.lift(Task.Pure(r));
  public function error(e:Defect<E>):Receiver<R,E>                             return Receiver.lift(Task.Fail(e));
  
  
  public function later(ft:Future<Outcome<R,Defect<E>>>):Receiver<R,E>         return Receiver.lift(Task.FutureOutcome(ft));
  public function lense(t:Task<R,E>):Receiver<R,E>                            return Receiver.lift(t);
  public function pause(work:Work):Terminal<R,E>                              return new WorkTerminal(work);
  
  public function inner<RR,EE>(join:Outcome<RR,Array<EE>> -> Void):Terminal<RR,EE>   return new SubTerminal(join);

  public function toTerminalApi():TerminalApi<R,E>                            return this;
}
class WorkTerminal<R,E> extends Terminal<R,E>{
  var work : Work;
  public function new(work:Work){
    super();
    this.work = work;
  }
  @:access(stx.async) private function handle(receiver:Receiver<R,E>):Receiver<R,E>{
    return Receiver.lift(Task.Pause(work,@:privateAccess receiver.prj()).toTaskApi());
  }
  override public function issue(res:Outcome<R,Defect<E>>):Receiver<R,E>                return handle(super.issue(res));
  override public function value(r:R):Receiver<R,E>                                    return handle(super.value(r));
  override public function error(e:Defect<E>):Receiver<R,E>                             return handle(super.error(e));
  
  override public function later(ft:Future<Outcome<R,Defect<E>>>):Receiver<R,E>         return handle(super.later(ft));
  override public function lense(t:Task<R,E>):Receiver<R,E>                            return handle(super.lense(t));
}
class SubTerminal<R,E> extends Terminal<R,E>{
  var handler : Outcome<R,Defect<E>> -> Void;
  public function new(handler){
    super();
    this.handler = handler;
  }
  @:access(stx.async) private function handle(receiver:Receiver<R,E>):Receiver<R,E>{
    return receiver.listen(handler);
  }
  override public function issue(res:Outcome<R,Defect<E>>):Receiver<R,E>                return handle(super.issue(res));
  override public function value(r:R):Receiver<R,E>                                    return handle(super.value(r));
  override public function error(e:Defect<E>):Receiver<R,E>                             return handle(super.error(e));
  
  override public function later(ft:Future<Outcome<R,Defect<E>>>):Receiver<R,E>         return handle(super.later(ft));
  override public function lense(t:Task<R,E>):Receiver<R,E>                            return handle(super.lense(t));
  
}
private abstract Receiver<R,E>(TaskApi<R,E>){
  static inline public function lift<R,E>(self:TaskApi<R,E>) return new Receiver(self);

  public inline function new(self:TaskApi<R,E>) this = self;

  public inline function after(res:Work):Work{
    return res.seq(lift(this).serve());
  }
  private inline function listen(fn:Outcome<R,Defect<E>>->Void):Receiver<R,E>{
    return lift(Task.Handler(this,fn));
  }
  public inline function serve():Work{
    return this.toWork();
  }
  private inline function prj():TaskApi<R,E>{
    return this;
  }
}