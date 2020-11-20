package stx.async;

import stx.async.task.term.*;

typedef TaskDef<R,E> = GoalDef<E> & {
  @:isVar public var id(get,null):String;
  public function get_id():String;

  public var result(get,null):Null<R>;
  public function get_result():Null<R>;

  @:isVar public var signal(get,null):tink.core.Signal<Noise>;
  public function get_signal():Signal<Noise>;

  public function toWork():Work;
  public function toTaskApi():TaskApi<R,E>;

  //public function identifier():String;
}
interface TaskApi<R,E> extends GoalApi<E>{
  @:isVar public var id(get,null):String;
  public function get_id():String;
  
  @:isVar public var result(get,null):Null<R>;
  public function get_result():Null<R>;

  @:isVar public var signal(get,null):tink.core.Signal<Noise>;
  public function get_signal():Signal<Noise>;

  public function toWork():Work;
  public function toTaskApi():TaskApi<R,E>;

  //public function identifier():String;
}
class TaskCls<T,E> implements TaskApi<T,E> extends Clazz{
  @:isVar public var id(get,null):String;
  public function get_id():String{
    return id == null ? id = __.uuid("xxxxx") : id;
  }

  public function pursue():Void {}
  public function escape():Void {}
  
  @:isVar public var defect(get,null):Defect<E>;
  public function get_defect():Defect<E> return this.defect == null ? this.defect = Defect.unit() : this.defect;

  @:isVar public var status(get,null):GoalStatus;
  public function get_status():GoalStatus return status;

  @:isVar public var result(get,null):Null<T>;
  public function get_result():Null<T>{
    return this.result;
  }
  @:isVar public var signal(get,null):Null<tink.core.Signal<Noise>>;
  public function get_signal(){
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
  public inline function toTaskApi():TaskApi<T,E>{
    return (this:TaskApi<T,E>);
  }
  public inline function toWork():Work{
    return Work.lift(this.toTaskApi());
  }
  
  public var loaded(get,null):Bool;
  public inline function get_loaded(){
    return this.status == Secured;
  }
  public var partial(get,null):Bool;
  public inline function get_partial(){
    return this.status.is_partial();
  }

  public function toString(){
    var name = this.identifier().split(".").last().defv('Task');
    return '$name:$id(${status.toString()})';
  }
}
@:using(stx.async.Task.TaskLift)
@:forward abstract Task<T,E>(TaskApi<T,E>) from TaskApi<T,E> to TaskApi<T,E>{
  static public var _(default,never) = TaskLift;
  static public inline function lift<T,E>(self:TaskApi<T,E>) return new Task(self);
  public function new(self) this = self;

  @:noUsing static public function FlatMap<T,Ti,E>(self:Task<T,E>,flat_map:T->Task<Ti,E>):Task<Ti,E>{
    return new FlatMap(self,flat_map);
  }
  @:noUsing static public function ThroughBind<T,Ti,E>(self:Task<T,E>,through_bind:Outcome<T,Defect<E>>->Task<Ti,E>):Task<Ti,E>{
    return new AnonThroughBind(self,through_bind);
  }
  @:noUsing static public function Handler<T,E>(self:Task<T,E>,fn:Outcome<T,Defect<E>>->Void):Task<T,E>{
    return new Handler(self,fn);
  }
  @:noUsing static public function FutureOutcome<T,E>(self:Future<Outcome<T,Defect<E>>>,?pos:Pos):Task<T,E>{
    return new FutureOutcome(self,pos);
  }
  @:noUsing static public function Later<T,E>(self:Future<Task<T,E>>):Task<T,E>{
    return lift(new Later(self));
  }
  @:noUsing static public function Thunk<T,E>(self:Void->T):Task<T,E>{
    return lift(new stx.async.task.term.Thunk(self));
  }
  @:noUsing static public function Pause<T,E>(work:Work,task:Task<T,E>):Task<T,E>{
    return lift(new stx.async.task.term.Pause(work,task));
  }
  @:noUsing static public function After<T,E>(task:Task<T,E>,work:Work):Task<T,E>{
    return lift(new stx.async.task.term.After(task,work));
  }
  @:noUsing static public function Map<T,Ti,E>(self:Task<T,E>,fn:T->Ti):Task<Ti,E>{
    return lift(new stx.async.task.term.Map(self,fn));
  }
  @:noUsing static public function Pure<T,E>(t:T):Task<T,E> return new Pure(t);
  @:noUsing static public function Fail<T,E>(e:Defect<E>):Task<T,E> return new Fail(e);

  @:noUsing static public function Par<T,Ti,E>(self:Task<T,E>,that:Task<Ti,E>):Task<Couple<T,Ti>,E> return new Par(self,that);
  @:noUsing static public function Seq<T,Ti,E>(self:Task<T,E>,that:Task<Ti,E>):Task<Couple<T,Ti>,E> return new Seq(self,that);

}
class TaskLift{
  
  static public function outcome<T,E>(self:Task<T,E>):Outcome<T,Defect<E>>{
    return __.option(self.defect).map(__.failure).def(() -> __.success(self.result));
  }  
  static public function map<T,Ti,E>(self:Task<T,E>,fn:T->Ti):Task<Ti,E>{
    return Task.Map(self,fn);
  }
  static public function flat_map<T,Ti,E>(self:Task<T,E>,fn:T->Task<Ti,E>):Task<Ti,E>{
    return Task.FlatMap(self,fn);
  }
}