package stx;

typedef TaskDef<R,E>  = stx.async.task.Def<R,E>;
typedef TaskApi<R,E>  = stx.async.task.Api<R,E>;
//typedef TaskCls<R,E>  = stx.async.task.Cls<R,E>;

typedef DeclaredApi   = stx.async.declared.Api;

typedef Task<R,E>           = stx.async.Task<R,E>;
typedef WorkApi             = stx.async.Work.WorkApi;
typedef Work                = stx.async.Work;
typedef Terminal<R,E>       = stx.async.Terminal<R,E>;
typedef TimerDef            = stx.async.Timer.TimerDef;
typedef Timer               = stx.async.Timer;
typedef GoalStatus          = stx.async.GoalStatus;
typedef LoopCls             = stx.async.Loop.LoopCls;
typedef Loop                = stx.async.Loop;
typedef Hook                = stx.async.Hook;
typedef HookTag             = stx.async.Hook.HookTag;
typedef LogicalClock        = stx.async.LogicalClock;
typedef TimeStamp           = stx.async.TimeStamp;
//typedef ResolverApi<R,E>    = stx.async.terminal.NewTerminal.ResolverApi<R,E>;
//typedef Resolver<R,E>       = stx.async.terminal.NewTerminal.Resolver<R,E>;

@:forward abstract Goal(GoalApi) from GoalApi to GoalApi{
  @:noUsing static public function lift(self) return new Goal(self);
  public function new(self) this = self;

  @:noUsing static public function Seq(lhs,rhs,?pos:Pos){
    return new stx.async.goal.term.Seq(lhs,rhs,pos);
  }
  @:noUsing static public function Par(array:Array<Goal>,?pos:Pos){
    return new stx.async.goal.term.Par(array,pos);
  }
  @:noUsing static public function Thunk(thunk,?pos:Pos){
    return new stx.async.goal.term.Thunk(thunk,pos);
  }
  // @:from public function fromTask<T,E>(task:Task<T,E>){
  //   return new stx.async
  // }
}
typedef GoalApi       = stx.async.goal.Api;
typedef GoalDef       = stx.async.goal.Def;

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