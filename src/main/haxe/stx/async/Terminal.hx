package stx.async;

interface TerminalApi<R,E>{  
  public function issue(res:Outcome<R,E>):Receiver<R,E>;
  public function value(r:R):Receiver<R,E>;
  public function error(err:E):Receiver<R,E>;

  public function defer(ft:Future<Outcome<R,E>>):Receiver<R,E>;

  public function inner<RR,EE>(join:Outcome<RR,EE> -> Void):Terminal<RR,EE>;
  

  public function toTerminalApi():TerminalApi<R,E>;
}
@:allow(stx) class Terminal<R,E> implements TerminalApi<R,E>{
  static public var ZERO = new Terminal();

  private function new(){}
  public function issue(res:Outcome<R,E>):Receiver<R,E>                       return res.fold(value,error);
  public function value(r:R):Receiver<R,E>                                    return Receiver.lift(Task.Pure(r));
  public function error(e:E):Receiver<R,E>                                    return Receiver.lift(Task.Fail(e));
  
  public function defer(ft:Future<Outcome<R,E>>):Receiver<R,E>                return Receiver.lift(Task.FutureOutcome(ft));
  
  public function inner<RR,EE>(join:Outcome<RR,EE> -> Void):Terminal<RR,EE>   return new SubTerminal(join);

  public function toTerminalApi():TerminalApi<R,E>                            return this;
}

class SubTerminal<R,E> extends Terminal<R,E>{
  var handler : Outcome<R,E> -> Void;
  public function new(handler){
    super();
    this.handler = handler;
  }
  @:access(stx.async) private function handle(receiver:Receiver<R,E>):Receiver<R,E>{
    return receiver.listen(handler);
  }
  override public function issue(res:Outcome<R,E>):Receiver<R,E>                       return handle(super.issue(res));
  override public function value(r:R):Receiver<R,E>                                    return handle(super.value(r));
  override public function error(e:E):Receiver<R,E>                                    return handle(super.error(e));
  
  override public function defer(ft:Future<Outcome<R,E>>):Receiver<R,E>                return handle(super.defer(ft));
  
}
private abstract Receiver<R,E>(TaskApi<R,E>){
  static public function lift<R,E>(self:TaskApi<R,E>) return new Receiver(self);

  public function new(self:TaskApi<R,E>) this = self;

  public inline function after(res:Work):Work{
    return res.seq(lift(this).serve());
  }
  private function listen(fn:Outcome<R,E>->Void):Receiver<R,E>{
    return lift(Task.Handler(this,fn));
  }
  public inline function serve():Work{
    return this.toWork();
  }
}