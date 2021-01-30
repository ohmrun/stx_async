package stx.async.terminal.term;

class Handler<R,E> extends Cls<R,E>{
  var handler : Outcome<R,Defect<E>> -> Void;
  public function new(handler,?pos:Pos){
    super(pos);
    this.handler  = handler;
  }
  override private inline function resolve(receiver:Receiver<R,E>,?pos:Pos):Receiver<R,E>{
    @:privateAccess return super.resolve(receiver.listen(handler),pos);
  }
}