package stx.async;

import stx.async.work.term.*;

typedef WorkApi = Task<Any,Any>;

@:using(stx.async.Work.WorkLift)
@:forward abstract Work(WorkApi) from WorkApi to WorkApi{
  @:noUsing static public function lift(self:WorkApi):Work{
    return new Work(self);
  }
  @:from @:noUsing static public function fromFutureWork(ft:Future<Work>):Work{
    return Task.Later(ft);
  }
  @:from static public function fromFunXX(fn:Void->Void):Work{
    return lift(new stx.async.work.term.Block(fn));
  }
  public function new(self) this = self;
 
  public function submit(?loop:Loop){
    __.log().debug('submit: $loop');
    __.option(loop).defv(Loop.ZERO).add(this);
  }
  public function crunch(?loop) stx.async.work.Crunch.apply(this,loop);
}
class WorkLift{
  static public function seq(self:Work,that:Work):Work{
    return Task.Seq(
      self,
      that
    );
  }
  static public function par(self:Work,that:Work):Work{
    return Task.Par(
      self,
      that
    );
  }
}