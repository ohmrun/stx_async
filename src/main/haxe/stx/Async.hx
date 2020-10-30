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
typedef Defect<E>     = stx.async.Defect<E>;

typedef TickDef = {
  public function delay(float:Null<Float>):Void;
  public function stop():Void;
}
class Stat{
  public var last(default,null):Float;
  public var duration(default,null):Float;
  public function new(){}
}