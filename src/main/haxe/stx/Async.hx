package stx;

import haxe.Timer;
import haxe.MainLoop;

import tink.CoreApi;

using stx.Fn;
using stx.Nano;
using stx.Pico;
using stx.Log;
using stx.Async;

import stx.pico.Either;

enum abstract AsyncState(UInt){

}
/*
interface BareMinimum<I,O>{
  public var goods(default,null):Null<O>;
  public var ready(default,null):Bool;
  public var state(default,null):ASyncState;


  public function assign(v:I):Void;
  public function attend(fn:O->Void):Void;
  public function pursue():Void;  
}
class AnonSyncBareMinimum<I,O,S> implements BareMinimum<I,O,S>{

}*/
class Async{
  static public function log(wildcard:Wildcard):Log{
    return new stx.Log().tag("stx.async");
  }
  static public function timer(wildcard:Wildcard){
    return new Timer();
  }
}
@:using(stx.Async.TaskControlLift)
enum TaskControl{
  Pursue;
  Escape;
}
class TaskControlLift{
  static public function fold<Z>(self:TaskControl,pursue:Void->Z,escape:Void->Z):Z{
    return switch(self){
      case Pursue: pursue();
      case Escape: escape();
    }
  }
}
interface TaskApi<T,E>{
  public function apply(control:TaskControl) : Slot<Either<Task<T,E>,Outcome<T,E>>>;

  public function asTaskApi():TaskApi<T,E>;
  public function asTask():Task<T,E>;

  public function toWork():Work;
}
class TaskBase<T,E> implements TaskApi<T,E>{
  public function apply(control:TaskControl) : Slot<Either<Task<T,E>,Outcome<T,E>>>{
    return Slot.Ready(Either.left(this.asTask()));
  }
  public inline function asTaskApi():TaskApi<T,E>{
    return this;
  }
  public inline function asTask():Task<T,E>{
    return this;
  }
  public function toWork():Work{
    return Work.lift(Task.Anon(
      apply.fn().then(
        (slot:Slot<Either<Task<T,E>,Outcome<T,E>>>) -> {
          return slot.map(
            (e:Either<Task<T,E>,Outcome<T,E>>) -> e.fold(
              next  -> Either.left(next.toWork().asTask()),
              _     -> stx.pico.Either.right(Outcome.success(Noise))
            )
          );
        }
      ).prj()
    ));
  }
}
class TaskFlatMap<T,Ti,E> extends TaskBase<Ti,E>{
  public var self     : Task<T,E>;
  public var flat_map : T -> Task<Ti,E>;

  public function new(self,flat_map){
    this.self     = self;
    this.flat_map = flat_map;
  }
  override public function apply(control:TaskControl) : Slot<Either<Task<Ti,E>,Outcome<Ti,E>>>{
    return self.apply(control).flat_map(
      (e) -> e.fold(
        (lhs) -> Slot.Ready(Left(new TaskFlatMap(lhs,flat_map).asTask())),
        (rhs) -> rhs.fold(
          o -> flat_map(o).apply(control),
          e -> Slot.Ready(Either.right(Outcome.failure(e)))
        )
      )
    );
  }
}
class TaskHandler<T,E> implements TaskApi<T,E> extends TaskBase<T,E>{
  var delegate  : Task<T,E>;
  var handler   : Outcome<T,E> -> Void;
  public function new(delegate,handler){
    this.delegate = delegate;
    this.handler = handler;
  }
  override public function apply(control:TaskControl): Slot<Either<Task<T,E>,Outcome<T,E>>>{
    return delegate.apply(control).map(
      (e) -> e.fold(
        lhs -> Either.left(new TaskHandler(lhs,handler).asTask()),
        rhs -> {
          handler(rhs);
          return stx.pico.Either.right(rhs);
        }
      )
    );
  }
}

class AnonTask<T,E> implements TaskApi<T,E> extends TaskBase<T,E>{
  var delegate : TaskControl -> Slot<Either<Task<T,E>,Outcome<T,E>>>;
  public function new(delegate){
    this.delegate = delegate;
  }
  override public function apply(control:TaskControl){
    return delegate(control);
  }
}
@:forward abstract Task<T,E>(TaskApi<T,E>) from TaskApi<T,E> to TaskApi<T,E>{
  public function new(self){
    this = self;
  }
  static public function Anon<T,E>(delegate):Task<T,E>{
    return new AnonTask(delegate);
  }
  static public function FlatMap<T,Ti,E>(self:Task<T,E>,flat_map:T->Task<Ti,E>):Task<Ti,E>{
    return new TaskFlatMap(self,flat_map);
  }
  public function pursue():Slot<Either<Task<T,E>,Outcome<T,E>>>{
    return this.apply(Pursue);
  }
  @:noUsing static public function pure<T>(t:T){
    return (_:TaskControl) -> Right(Success(t));
  }
}
class TaskLift{
  
}
class SlotTask<T,E> extends TaskBase<T,E>{
  var slot : Slot<Outcome<T,E>>;

  public function new(slot){
    this.slot = slot;
  }
  override public function apply(control:TaskControl){
    return switch(control){
      case Pursue : slot.map(Either.right);
      case Escape : throw(slot);
    }
  }
}
class Loop{
  static public var instance = new Loop();

  public function new(){
    this.suspended  = 0;
    this.threads    = [];
  }
  var event     : MainEvent;
  var suspended : Int;
  var threads   : Array<Work>;

  public function add(work:Work){
    threads.push(work);
    if(event == null){
      event = MainLoop.add(rec);
    }
  }
  function rec(){
    __.log()("Loop.rec");
    var next = __.option(threads.shift());
    __.log()('has next? $next');
    if(next.is_defined()){
      for(work in next){
        var selection = work.apply(Pursue);
        __.log()('$selection');
        var ready     = selection.ready;
        if(!ready){
          suspended = suspended + 1;
        }
        selection.handle(
          (x) -> {
            if(!ready){
              suspended = suspended - 1;
            }
            __.log()('handle: $x');
            x.fold(
              function (work:Task<Noise,Noise>):Void{
                __.log()('push: $work');
                threads.push(Work.lift(work));
              },
              oc -> oc.fold(
                (_) -> {},
                on_error
              )
            );
          }
        );
      }
    }else if(suspended > 0){
      //Let it run
      //TODO backoff algorhithm
    }else{
      event.stop();
    }
  }
  dynamic function on_error(e:Noise):Void{
    __.crack(e);
  }
}
class Stat{
  public var last(default,null):Float;
  public var duration(default,null):Float;
  public function new(){}
}
typedef WorkApi = TaskApi<Noise,Noise>;


class FutureWork implements WorkApi extends TaskBase<Noise,Noise>{
  var future : Future<Work>;
  public function new(future){
    this.future = future;
  }
  override public function apply(control){
    return Slot.Guard(future).flat_map(
      work -> work.apply(control)
    );
  }
  public function step(){
    return apply(Pursue);
  }
}
@:forward abstract Work(WorkApi) from WorkApi to WorkApi{
  @:noUsing static public function lift(self:WorkApi):Work{
    return new Work(self);
  }
  @:from @:noUsing static public function fromFutureWork(ft:Future<Work>):Work{
    return new FutureWork(ft);
  }

  public function new(self) this = self;
  public function seq(that:Work):Work{
    return new WorkSeq(this,that);
  }
  public function par(that:Work):Work{
    return new WorkPar(this,that);
  }
  public function submit(?loop){
    Loop.instance.add(this);
  }
  public function crunch(?loop){
    var self      = this;
    var cont      = true;
    var suspended = false;
    var backoff   = 0.2;

    while(true == cont){
      if(!suspended){
        var response = self.apply(Pursue);
        if(response.ready){
          var value = response.data;
          switch value {
            case Left(next) : 
              self  = next;
            case Right(_)   :
              cont  = false;
          }
        }else{
          suspended = true;
          response.guard.handle(
            (e) -> switch(e){
              case Left(next) : 
                backoff   = 1.22;
                suspended = false;
                self      = next;
                null;
              case Right(_)   : 
                cont      = false;
                null;
            }
          );
        }
      }else{
        #if sys
          Sys.sleep(backoff);
          backoff = backoff * 1.22;
        #end
      }
    }
  }
}
class WorkBase implements WorkApi extends TaskBase<Noise,Noise>{
  public function step(){
    return this.apply(Pursue);
  }
}
class WorkSeq implements WorkApi extends WorkBase{
  var lhs     : Work;
  var rhs     : Work;
  var cursor  : Bool; 

  public function new(lhs,rhs){
    this.cursor   = false;
    this.lhs      = lhs;
    this.rhs      = rhs;
  }
  override public function apply(control:TaskControl):Slot<Either<Task<Noise,Noise>,Outcome<Noise,Noise>>>{
    return switch(control){
      case Pursue : 
        switch(cursor){
          case false : 
            lhs.apply(Pursue).map(
              e ->  e.fold(
                _ -> Left(this.asTask()),
                _ -> {
                  this.cursor = true;
                  return Left(this.asTask());
                }
              )
            );
          case true : 
            rhs.apply(Pursue).map(
              e -> e.fold(
                _ -> Either.left(this.asTask()),
                _ -> stx.pico.Either.right(Outcome.success(Noise))
              )
            );
        }
      case Escape : 
        this.lhs.apply(Escape);//TODO hmmm.
        this.rhs.apply(Escape);
        Slot.Ready(Either.right(Outcome.success(Noise)));
    }
  }
}
class WorkPar implements WorkApi extends WorkBase{
  var lhs     : WorkApi;
  var rhs     : WorkApi;

  public function new(lhs,rhs){
    this.lhs      = lhs;
    this.rhs      = rhs;
  }
  override public function apply(control:TaskControl):Slot<Either<Task<Noise,Noise>,Outcome<Noise,Noise>>>{
    return this.lhs.apply(control).zip(
      this.rhs.apply(control)
    ).map(
      (tp) -> tp.decouple(
        (l,r) -> switch([l,r]){
          case [Left(next0),Left(next1)] : Either.left(new WorkPar(next0,next1).asTask());
          case [Right(_),Left(next)]     : Either.left(next.asTask());
          case [Left(next),Right(_)]     : Either.left(next.asTask());
          default                        : Either.right(Outcome.success(Noise));
        }
      )
    );
  }
}

interface TerminalApi<R,E>{  
  public function issue(res:Outcome<R,E>):Receiver<R,E>;
  public function value(r:R):Receiver<R,E>;
  public function error(err:E):Receiver<R,E>;

  public function defer(ft:Slot<Outcome<R,E>>):Receiver<R,E>;

  public function inner<RR,EE>(join:Outcome<RR,EE> -> Void):Terminal<RR,EE>;

  public function toTerminalApi():TerminalApi<R,E>;
}
class Terminal<R,E> implements TerminalApi<R,E>{
  static public var ZERO = new Terminal();

  public function new(){}
  public function issue(res:Outcome<R,E>):Receiver<R,E>{
    return defer(Slot.Ready(res));
  }
  public function value(r:R):Receiver<R,E>{
    return issue(Success(r));
  }
  public function error(err:E):Receiver<R,E>{
    return issue(Failure(err));
  }
  public function defer(ft:Slot<Outcome<R,E>>):Receiver<R,E>{
    return new SlotTask(ft);
  }
  public function inner<RR,EE>(join:Outcome<RR,EE> -> Void):Terminal<RR,EE>{
    return new SubTerminal(join);
  }
  public function toTerminalApi():TerminalApi<R,E>{
    return this;
  }
}
class SubTerminal<R,E> implements TerminalApi<R,E> extends Terminal<R,E>{
  private var join : Outcome<R,E> -> Void;
  public function new(join){
    super();
    this.join = join;
  }
  override public function defer(ft:Slot<Outcome<R,E>>):Receiver<R,E>{
    var task     = new SlotTask(ft);
    var handler  = new TaskHandler(task.asTask(),join);
    return handler;
  }
}
abstract Receiver<R,E>(TaskApi<R,E>) from TaskApi<R,E>{
  public inline function after(res:Work):Work{
    return res.seq(this.toWork());
  }
  public inline function serve():Work{
    return this.toWork();
  }
}

typedef TimerDef = {
  var created(default,null) : Float;
}
@:forward abstract Timer(TimerDef) from TimerDef to TimerDef{
  public function new(?self){
    if(self == null){
      this = unit();
    }else{
      this = self;
    }
  }
  static public function pure(v:Float):Timer{
    return {
      created : v
    };
  }
  static public function unit():Timer{
    return pure(mark());
  }
  static public function mark():Float{
    return haxe.Timer.stamp();
  }
  function copy(?created:Float){
    return pure(created == null ? this.created : created);
  }
  public function start():Timer{
    return copy(mark());
  }
  public function since():Float{
    return mark() - this.created;
  }
  function prj(){
    return this;
  }
}