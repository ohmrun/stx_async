package stx.async.terminal;

abstract Receiver<R,E>(TaskApi<R,E>){
  static inline public function lift<R,E>(self:TaskApi<R,E>) return new Receiver(self);

  private inline function new(self:TaskApi<R,E>) this = self;

  public inline function after(res:Work):Work{
    return res.seq(lift(this).serve());
  }
  private inline function listen(fn:Outcome<R,Defect<E>>->Void):Receiver<R,E>{
    return lift(Task.Handler(this,fn));
  }
  public inline function serve():Work{
    return this.toWork(this.pos);
  }
  public inline function prj():TaskApi<R,E>{
    return this;
  }
  public function toString(){
    return 'Receiver($this)';
  }
}