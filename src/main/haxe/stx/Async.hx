package stx;
class Async{
  static public function timer(wildcard:Wildcard) return new Timer();
}

typedef TaskDef<R,E>  = stx.async.Task.TaskDef<R,E>;
typedef TaskApi<R,E>  = stx.async.Task.TaskApi<R,E>;
typedef TaskCls<R,E>  = stx.async.Task.TaskCls<R,E>;
typedef Task<R,E>     = stx.async.Task<R,E>;
typedef WorkApi       = stx.async.Work.WorkApi;
typedef Work          = stx.async.Work;
typedef Terminal<R,E> = stx.async.Terminal<R,E>;
typedef TimerDef      = stx.async.Timer.TimerDef;
typedef Timer         = stx.async.Timer;
typedef GoalStatus    = stx.async.GoalStatus;
typedef LoopCls       = stx.async.Loop.LoopCls;
typedef Loop          = stx.async.Loop;
typedef Hook          = stx.async.Hook;
typedef HookTag       = stx.async.Hook.HookTag;
typedef LogicalClock  = stx.async.LogicalClock;
typedef TimeStamp     = stx.async.TimeStamp;
typedef GoalApi<E>    = stx.async.GoalApi<E>;
typedef GoalDef<E>    = stx.async.GoalDef<E>;

#if target.threaded
typedef RuntimeApi    = stx.async.Runtime.RuntimeApi;
typedef Runtime       = stx.async.Runtime;

typedef ThreadApi     = stx.async.Thread.ThreadApi;
typedef ThreadDef     = stx.async.Thread.ThreadDef;
typedef Thread        = stx.async.Thread;
typedef ThreadMap     = stx.async.loop.term.Thread.ThreadMap;
#end 
typedef TickDef = {
  public function delay(float:Null<Float>):Void;
  public function stop():Void;
}
class Stat{
  public var last(default,null):Float;
  public var duration(default,null):Float;
  public function new(){}
}
class LiftDefectNoiseToErr{
  static public inline function toErr<E>(e:Defect<Noise>,?pos:Pos):Err<E>{
    return __.fault().err(E_UndefinedError);
  }
}