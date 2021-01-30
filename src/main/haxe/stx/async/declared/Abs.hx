package stx.async.declared;

abstract class Abs implements Api extends Clazz{
  public var pos(default,null):Pos;
  
  abstract public function get_id():Int;
  
  public function new(?pos:Pos){
    super();
    this.pos = pos;  
  }
  public function equals(that:DeclaredApi){
    return this.get_id() == that.get_id();
  }
}