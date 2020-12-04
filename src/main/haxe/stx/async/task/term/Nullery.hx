package stx.async.task.term;

class Nullery<Ri,Rii,E> extends Delegation<Rii,Task<Ri,E>>{
  override public inline function get_defect():Defect<E>{
    return delegation.defect;
  }
  override public inline function set_defect(v:Defect<E>):Defect<E>{
    return this.delegation.defect = v;
  }
  override public inline function get_result():Null<Ri>{
    return null;
  }
}