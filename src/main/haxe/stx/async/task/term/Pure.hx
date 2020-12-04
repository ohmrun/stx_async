package stx.async.task.term;

class Pure<T,E> extends Stamp<T,E>{

  public function new(result,?pos:Pos){
    super(__.success(result),pos);
  }
  override public function get_status(){
    return Secured;
  }
  override public function get_loaded(){
    return true;
  }
  override public function pursue(){}
}
