package stx.async;

import stx.async.task.term.ThroughBind;

using stx.async.Terminal;

function log(wildcard:Wildcard){
  return stx.async.Log.log(__).tag(__.here().lift().identifier());
}
interface TerminalApi<R,E>{  
  public var id(get,null):Int;
  public function get_id():Int;

  public function issue(res:Outcome<R,Defect<E>>):Receiver<R,E>;
  public function value(r:R):Receiver<R,E>;
  public function error(err:Defect<E>):Receiver<R,E>;

  public function later(ft:Future<Outcome<R,Defect<E>>>):Receiver<R,E>;
  public function lense(t:Task<R,E>):Receiver<R,E>;
  public function pause(n:Work):Terminal<R,E>;
  public function joint<RR,EE>(joiner:Outcome<RR,Defect<EE>> -> Work):Terminal<RR,EE>;

  public function inner<RR,EE>(join:Outcome<RR,Array<EE>> -> Void):Terminal<RR,EE>;  

  public function toTerminalApi():TerminalApi<R,E>;
}
@:forward abstract Terminal<R,E>(TerminalApi<R,E>) from TerminalApi<R,E> to TerminalApi<R,E>{
  static private var ZERO = new Terminal();
  public function new(?self:Terminal<R,E>){
    this = __.option(self).def(() -> this = @:privateAccess new TerminalCls());
  }
  static public function identifier(){
    return __.here().lift().identifier();
  }
}
@:allow(stx.arrowlet.term.Thread) class TerminalCls<R,E> implements TerminalApi<R,E>{
  private var counter = 0;

  @:isVar public var id(get,null):Int;
  public function get_id():Int{
    return this.id;
  }
  private function new(){
    this.id = counter++;
    ////__.log().debug('$id');
  }
  public function issue(res:Outcome<R,Defect<E>>):Receiver<R,E>                           {
    var out = res.fold(value,error);
    return out;
  }
  public function value(r:R):Receiver<R,E>                                                return Receiver.lift(Task.Pure(r));
  public function error(e:Defect<E>):Receiver<R,E>                                        return Receiver.lift(Task.Fail(e));
  
  
  public function later(ft:Future<Outcome<R,Defect<E>>>):Receiver<R,E>                    return Receiver.lift(Task.FutureOutcome(ft));
  
  public function lense(t:Task<R,E>):Receiver<R,E>                                        return Receiver.lift(t);
  public function pause(work:Work):Terminal<R,E>                                          return (new WorkTerminal(work));
  public function inner<RR,EE>(join:Outcome<RR,Array<EE>> -> Void):Terminal<RR,EE>        return (new SubTerminal(join));
  public function joint<RR,EE>(joiner:Outcome<RR,Defect<EE>> -> Work):Terminal<RR,EE>     return (new JointTerminal(this,joiner));

  public function toTerminalApi():TerminalApi<R,E>                                        return this;

  public function toString(){ return 'Terminal($id)'; }
}
class TerminalTask<T,E> extends TaskCls<T,E>{
  var state     : Bool;
  var delegate  : Task<T,E>;
  var work      : Work;

  dynamic function joiner(outcome:Outcome<T,Defect<E>>):Work{
    return Work.ZERO;
  }
  public function new(delegate,joiner:Outcome<T,Defect<E>>->Work){
    super();
    this.delegate = delegate;
    this.joiner   = joiner;
    this.state    = false;
  }
  override inline public function pursue(){
    switch(state){
      case false :
        switch(delegate.status){
          case Problem : 
            this.work   = joiner(__.failure(delegate.defect));
            this.defect = delegate.defect;
            this.handle_work();
          case Pending : 
            delegate.pursue();
          case Applied : 
            delegate.pursue();
            this.work  = delegate.defect.is_defined().if_else(
              () -> {
                this.defect = delegate.defect;
                joiner(__.failure(delegate.defect));
              },
              () -> {
                this.result = delegate.result;
                joiner(__.success(delegate.result));
              }
            );
            this.handle_work();
          case Working :
          case Waiting : 
            this.init_signal();
            this.delegate.signal.nextTime().handle(
              (_) -> {
                this.trigger.trigger(Noise);
              }
            );
          case Secured : 
            this.result = delegate.result;
            this.work   = joiner(__.success(this.delegate.result));
            this.handle_work();
        }
      case true :
        handle_work();
    }
  }
  private inline function handle_work(){
    this.state = true;
    switch(work.status){
      case Problem : 
        this.defect = this.delegate.defect.concat(this.work.defect.entype());
        this.status   = Problem;
      case Pending : 
        work.pursue();
        this.status   = work.status;
      case Applied : 
        work.pursue();
        this.status   = work.status;
      case  Working : 
        this.status = Working;
      case Waiting  : 
        this.init_signal();
        this.work.signal.nextTime().handle(
          (_) -> {
            this.trigger.trigger(Noise);
          }
        );
        this.status = Waiting;
      case Secured  : 
        this.status = Secured;
    }
  }
}
class TerminalLog<RR,EE> implements TerminalApi<RR,EE>{
  public var id(get,null):Int;
  public function get_id():Int{
    return delegate.id;
  }
  public var delegate(default,null):Terminal<RR,EE>;
  public function new(delegate){
    this.delegate = delegate;
  }
  public function issue(res:Outcome<RR,Defect<EE>>):Receiver<RR,EE>{
    //__.log().debug('issue: $res on $id');
    return delegate.issue(res);
  }
  public function value(r:RR):Receiver<RR,EE>{
    //__.log().debug('value: $r on $id');
    return delegate.value(r);
  }
  public function error(e:Defect<EE>):Receiver<RR,EE>{
    //__.log().debug('error: $e on $id');
    return delegate.error(e);
  }
  
  public function later(ft:Future<Outcome<RR,Defect<EE>>>):Receiver<RR,EE>{
    //__.log().debug('later on $id');
    return delegate.later(ft);
  }
  public function inner<RR,EE>(join:Outcome<RR,Array<EE>> -> Void):Terminal<RR,EE>{
    //__.log().debug('inner on $id');
    return delegate.inner(join);
  }
  public function lense(t:Task<RR,EE>):Receiver<RR,EE>{
    //__.log().debug('lense on $id for $t');
    return delegate.lense(t);
  }
  public function joint<RRR,EEE>(joiner:Outcome<RRR,Defect<EEE>> -> Work):Terminal<RRR,EEE>{
    //__.log().debug('joint on $id');
    return delegate.joint(joiner);
  }
  public function pause(work:Work):Terminal<RR,EE>{
    //__.log().debug('pause on $id by $work');
    return delegate.pause(work);
  }
  public function toTerminalApi(){
    return this;
  }
}
class JointTerminal<R,RR,E,EE> extends TerminalCls<RR,EE>{
  //var source : Terminal<R,E>;
  public var complete : Bool;

  dynamic function joiner(outcome:Outcome<RR,Defect<EE>>):Work{
    return Work.ZERO;
  }
  
  public function new(source:Terminal<R,E>,joiner){
    super();
    var idx       = 1;
    this.complete = false;
    this.joiner   = joiner;
    // this.joiner = function(outcome:Outcome<RR,Defect<EE>>):Work{
    //   if(this.complete == true){
    //     throw 'joint called twice';
    //   }
    //   this.complete = true;
    //   var result : Work = joiner(outcome);
    //   //__.log().debug('$id:$idx -> $result');
    //   idx++;
    //   return result;
    // }
  }
  @:access(stx.async) private function handle(receiver:Receiver<RR,EE>):Receiver<RR,EE>{
    return Receiver.lift(new TerminalTask(receiver.prj(),joiner));
  }
  override inline public function issue(res:Outcome<RR,Defect<EE>>):Receiver<RR,EE>                    return handle(super.issue(res));
  override inline public function value(r:RR):Receiver<RR,EE>                                          return handle(super.value(r));
  override inline public function error(e:Defect<EE>):Receiver<RR,EE>                                  return handle(super.error(e));
  
  override inline public function later(ft:Future<Outcome<RR,Defect<EE>>>):Receiver<RR,EE>             return handle(super.later(ft));
  override inline public function lense(t:Task<RR,EE>):Receiver<RR,EE>                                 return handle(super.lense(t));
}
class WorkTerminal<R,E> extends TerminalCls<R,E>{
  var work : Work;
  public function new(work:Work){
    super();
    this.work = work;
  }
  @:access(stx.async) private function handle(receiver:Receiver<R,E>):Receiver<R,E>{
    return Receiver.lift(Task.Pause(work,@:privateAccess receiver.prj()).toTaskApi());
  }
  override public function issue(res:Outcome<R,Defect<E>>):Receiver<R,E>                return handle(super.issue(res));
  override public function value(r:R):Receiver<R,E>                                     return handle(super.value(r));
  override public function error(e:Defect<E>):Receiver<R,E>                             return handle(super.error(e));
  
  override public function later(ft:Future<Outcome<R,Defect<E>>>):Receiver<R,E>         return handle(super.later(ft));
  override public function lense(t:Task<R,E>):Receiver<R,E>                             return handle(super.lense(t));


  
}
class SubTerminal<R,E> extends TerminalCls<R,E>{
  var handler : Outcome<R,Defect<E>> -> Void;
  public function new(handler){
    super();
    this.handler = handler;
  }
  @:access(stx.async) private function handle(receiver:Receiver<R,E>):Receiver<R,E>{
    return receiver.listen(handler);
  }
  override public function issue(res:Outcome<R,Defect<E>>):Receiver<R,E>                return handle(super.issue(res));
  override public function value(r:R):Receiver<R,E>                                     return handle(super.value(r));
  override public function error(e:Defect<E>):Receiver<R,E>                             return handle(super.error(e));
  
  override public function later(ft:Future<Outcome<R,Defect<E>>>):Receiver<R,E>         return handle(super.later(ft));
  override public function lense(t:Task<R,E>):Receiver<R,E>                             return handle(super.lense(t));
  
}
private abstract Receiver<R,E>(TaskApi<R,E>){
  static inline public function lift<R,E>(self:TaskApi<R,E>) return new Receiver(self);

  private inline function new(self:TaskApi<R,E>) this = self;

  public inline function after(res:Work):Work{
    return res.seq(lift(this).serve());
  }
  private inline function listen(fn:Outcome<R,Defect<E>>->Void):Receiver<R,E>{
    return lift(Task.Handler(this,fn));
  }
  public inline function serve():Work{
    return this.toWork();
  }
  private inline function prj():TaskApi<R,E>{
    return this;
  }
}