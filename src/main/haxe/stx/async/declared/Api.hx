package stx.async.declared;

interface Api extends IFaze{
  public var pos(default,null):Pos;
  
  public function get_id():Int;

  public function equals(that:Api):Bool;
}