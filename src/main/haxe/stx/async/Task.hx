package stx.async;

import stx.async.task.term.*;

@:using(stx.async.Task.TaskLift)
@:forward abstract Task<T,E>(TaskApi<T,E>) from TaskApi<T,E> to TaskApi<T,E>{
  static public var counter : Int = 0;
  static public var _(default,never) = TaskLift;
  static public inline function lift<T,E>(self:TaskApi<T,E>) return new Task(self);
  public inline function new(self) this = self;

  @:noUsing static public function AnonFlatMap<T,Ti,E>(self:Task<T,E>,flat_map:T->Task<Ti,E>,?pos:Pos):Task<Ti,E>{
    return new AnonFlatMap(self,flat_map,pos);
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
  @:noUsing static public function Pause<T,E>(work:Work,task:Task<T,E>,?pos:Pos):Task<T,E>{
    return lift(new stx.async.task.term.Pause(work,task,pos));
  }
  @:noUsing static public function After<T,E>(task:Task<T,E>,work:Work,?pos:Pos):Task<T,E>{
    return lift(new stx.async.task.term.After(task,work,pos));
  }
  @:noUsing static public function Map<T,Ti,E>(self:Task<T,E>,fn:T->Ti):Task<Ti,E>{
    return lift(new stx.async.task.term.Map(self,fn));
  }
  @:noUsing static public function Logging<T,E>(self:Task<T,E>,?logging,?showing):Task<T,E>{
    return lift(new stx.async.task.term.Logging(self,logging,showing));
  }
  @:noUsing static public function At<T,E>(self:Task<T,E>,?pos:Pos):Task<T,E>{
    return lift(new stx.async.task.term.At(self,pos));
  }
  @:noUsing static public function Many<T,E>(tasks:Array<Task<T,E>>,?pos:Pos):Task<Array<T>,E>{
    return lift(new stx.async.task.term.Many(tasks,pos));
  }
  @:noUsing static public function Pure<T,E>(t:T,?pos:Pos):Task<T,E> return new Pure(t,pos);
  @:noUsing static public function Fail<T,E>(e:Defect<E>,?pos:Pos):Task<T,E> return new Fail(e,pos);

  @:noUsing static public function Par<T,Ti,E>(self:Task<T,E>,that:Task<Ti,E>,?pos:Pos):Task<Couple<T,Ti>,E> return new Par(self,that,pos);
  @:noUsing static public function Seq<T,Ti,E>(self:Task<T,E>,that:Task<Ti,E>,?pos:Pos):Task<Couple<T,Ti>,E> return new Seq(self,that,pos);

}
class TaskLift{ 
  static public function outcome<T,E>(self:Task<T,E>):Outcome<T,Defect<E>>{
    return __.option(self.get_defect()).map(__.failure).def(() -> __.success(self.get_result()));
  }  
  static public function map<T,Ti,E>(self:Task<T,E>,fn:T->Ti):Task<Ti,E>{
    return Task.Map(self,fn);
  }
  static public function flat_map<T,Ti,E>(self:Task<T,E>,fn:T->Task<Ti,E>):Task<Ti,E>{
  return Task.AnonFlatMap(self,fn);
  }
}