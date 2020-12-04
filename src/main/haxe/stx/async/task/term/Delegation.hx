package stx.async.task.term;

abstract class Delegation<R,X,E> extends stx.async.task.Delegate<R,E>{
  public var delegation(default,null):X;
  public function new(delegation:X,?pos:Pos){
    super(pos);
    this.delegation = delegation;
  }
}