package stx.async.work.term;

class At extends Delegate{
  public function new(delegate:WorkApi,?pos:Pos){
    super(delegate);
    this.pos = pos;
  }
}