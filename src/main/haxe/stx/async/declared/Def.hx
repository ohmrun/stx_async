package stx.async.declared;

typedef Def = {
  public var pos(default,null):Pos;
  
  public function get_id():Int;

  public function equals(that:DeclaredApi):Bool;
}