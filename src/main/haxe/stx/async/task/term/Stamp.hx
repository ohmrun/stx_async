package stx.async.task.term;

class Stamp<T,E> extends stx.async.task.Delegate<T,E>{
  @:isVar var id(get,null):Int;
  override public function get_id(){
    return this.id;
  }
  var delegate : Outcome<T,Defect<E>>;
  public inline function new(outcome:Outcome<T,Defect<E>>,?pos:Pos){
    super(pos);
    this.id       = Counter.next();
    this.delegate = outcome;
  }
  override public function get_defect(){
    return delegate.fold(
      (_) -> [],
      (e) -> e
    );
  }  
  override public function get_result(){
    return delegate.fold(
      (r) -> r,
      (_) -> null
    );
  }
  override public function toString(){
    return 'Stamp($delegate)';
  }
  
  override public function get_loaded(){
    return true;
  }
  override public function get_status(){
    return Secured;
  }
  
  override public function pursue(){}
  override public function escape(){}
  override public function update(){}

}
