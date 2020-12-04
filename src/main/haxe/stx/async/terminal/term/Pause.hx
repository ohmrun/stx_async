package stx.async.terminal.term;

class Pause<R,E> extends Cls<R,E>{
  var work : stx.async.Work;

  public function new(work:stx.async.Work,?pos:Pos){
    __.log()('terminal.Pause.new');
    super(pos);
    this.work = work;
  }
  @:access(stx.async) override private inline function resolve(receiver:Receiver<R,E>,?pos:Pos):Receiver<R,E>{
    return super.resolve(Receiver.lift(Task.Pause(work,@:privateAccess receiver.prj()).toTaskApi()));
  }
}