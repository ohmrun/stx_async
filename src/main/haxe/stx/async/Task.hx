package stx.async;

import stx.async.task.term.*;

interface TaskApi<R,E> extends GoalApi<E>{
  public var result(default,null):Null<R>;
  @:isVar public var signal(get,null):tink.core.Signal<Noise>;
  private function get_signal():Signal<Noise>;

  public function toWork():Work;
  public function toTaskApi():TaskApi<R,E>;

}
class TaskCls<T,E> implements TaskApi<T,E> extends Clazz{
  public function pursue():Void {}
  public function escape():Void {}
  
  @:isVar public var defect(get,null):Null<E>;
  private function get_defect():Null<E> return defect;

  @:isVar public var status(get,null):GoalStatus;
  private function get_status():GoalStatus return status;

  public var result(default,null):Null<T>;
  @:isVar public var signal(get,null):Null<tink.core.Signal<Noise>>;
  private function get_signal(){
    if(this.signal == null){
      init_signal();
    }
    return this.signal;
  }
         var trigger:tink.core.Signal.SignalTrigger<Noise>;

  public function new(){
    super();
    this.status = Pending;
  }

  private inline function init_signal(){
    if(this.trigger == null){
      this.trigger = tink.core.Signal.trigger();
      this.signal  = trigger.asSignal();
    }
  }
  public function toTaskApi():TaskApi<T,E>{
    return this;
  }
  public function toWork():Work{
    return Work.lift(this.toTaskApi());
  }
  
  public var loaded(get,null):Bool;
  private inline function get_loaded(){
    return this.status == Secured;
  }
}
@:using(stx.async.Task.TaskLift)
@:forward abstract Task<T,E>(TaskApi<T,E>) from TaskApi<T,E> to TaskApi<T,E>{
  static public function lift<T,E>(self:TaskApi<T,E>) return new Task(self);
  public function new(self) this = self;

  @:noUsing static public function FlatMap<T,Ti,E>(self:Task<T,E>,flat_map:T->Task<Ti,E>):Task<Ti,E>{
    return new FlatMap(self,flat_map);
  }
  @:noUsing static public function Handler<T,E>(self:Task<T,E>,fn:Outcome<T,E>->Void):Task<T,E>{
    return new Handler(self,fn);
  }
  @:noUsing static public function FutureOutcome<T,E>(self:Future<Outcome<T,E>>):Task<T,E>{
    return new FutureOutcome(self);
  }
  @:noUsing static public function Later<T,E>(self:Future<Task<T,E>>):Task<T,E>{
    return lift(new Later(self));
  }
  @:noUsing static public function Thunk<T,E>(self:Void->T):Task<T,E>{
    return lift(new stx.async.task.term.Thunk(self));
  }
  @:noUsing static public function Pure<T,E>(t:T):Task<T,E> return new Pure(t);
  @:noUsing static public function Fail<T,E>(e:E):Task<T,E> return new Fail(e);

  @:noUsing static public function Par<T,Ti,E>(self:Task<T,E>,that:Task<Ti,E>):Task<Couple<T,Ti>,E> return new Par(self,that);
  @:noUsing static public function Seq<T,Ti,E>(self:Task<T,E>,that:Task<Ti,E>):Task<Couple<T,Ti>,E> return new Seq(self,that);
}
class TaskLift{
  
}