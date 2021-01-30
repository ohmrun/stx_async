package stx.async.task.term;

class Unit<R,E> extends Stamp<R,E>{
  public function new(?pos:Pos){
    super(__.success(null),pos);
  }
}