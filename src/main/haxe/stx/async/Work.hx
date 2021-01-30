package stx.async;

import stx.async.work.term.*;

typedef WorkApi = Null<TaskApi<Any,Dynamic>>;

@:using(stx.async.Work.WorkLift)
@:forward abstract Work(WorkApi) from WorkApi to WorkApi{
  @:noUsing static public inline function lift(self:WorkApi):Work{
    return new Work(self);
  }
  static public var ZERO(default,null):Work = Unit();
  
  @:noUsing static public inline function unit():Work{
    return Unit();
  }
  @:noUsing static public inline function Unit():Work{
    return new stx.async.work.term.Unit().toWork();
  }
  @:noUsing static public inline function At(delegate:Work,?pos:Pos):Work{
    return new stx.async.work.term.At(delegate,pos).toWork();
  }
  @:noUsing static public inline function Canceller(delegate:Work,fn:Void->Void):Work{
    return new stx.async.work.term.Canceller(delegate,fn).toWork();
  }
  @:noUsing static public inline function Delegate(delegate:WorkApi):Work{
    return new stx.async.work.term.Delegate(delegate).toWork();
  }
  @:noUsing static public inline function Shim(delegate:Task<Dynamic,Dynamic>):Work{
    return new stx.async.work.term.Shim(delegate).toWork();
  }
  @:from @:noUsing static public function fromFutureWork(ft:Future<Work>):Work{
    return Task.Later(ft.map(work -> work.toTaskApi())).toWork();
  }
  @:from @:noUsing static public function fromGoal(goal:stx.async.goal.Api):Work{
    return new stx.async.work.term.Goal(goal);
  }
  @:from @:noUsing static public function Stamp(outcome:Outcome<Any,Defect<Dynamic>>):Work{
    return new stx.async.work.term.Stamp(outcome);
  }
  @:from static public function fromFunXX(fn:Void->Void):Work{
    return lift(new stx.async.work.term.Block(fn));
  }
  public inline function new(self) this = self;
 
  public function submit(?loop:Loop){
    loop = __.option(loop).defv(Loop.ZERO);
    //////__.log().debug('submit $this to: $loop');
    if(this!=null){
      loop.add(this);
    }
  }
  public function latch<E>():Task<Any,E>{
    return cast this;
  }
  public function carrying<T,E>(oc:Outcome<T,Defect<E>>):Task<T,E>{
    return new stx.async.task.term.Pause(this,new stx.async.task.term.Stamp(oc));
  }
  public inline function crunch(?loop) stx.async.work.Crunch.apply(this,loop);
}
class WorkLift{
  static public inline function seq(self:Work,that:Work):Work{
    return self == null ? that : that == null ? null : Task.Seq(self.toTaskApi(),that.toTaskApi()).toWork();
  }
  static public inline function par(self:Work,that:Work):Work{
    return self == null ? that : that == null ? null : Task.Par(self.toTaskApi(),that.toTaskApi()).toWork();
  }
}