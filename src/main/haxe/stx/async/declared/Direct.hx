package stx.async.declared;

class Direct extends Abs{
  @:isVar public var id(get,null) : Int;
  public function get_id(){
    return this.id;
  }
  public function new(?pos:Pos){
    super(pos);
    this.id = Counter.next();
  }
}