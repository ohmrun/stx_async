package stx.async.work.term;

class Stamp extends stx.async.task.Direct<Any,Dynamic>{
  var delegate : Outcome<Any,Defect<Dynamic>>;
  public inline function new(outcome:Outcome<Any,Defect<Dynamic>>){
    super();
    this.delegate = outcome;
    this.status   = Secured;
  }
  override public function get_defect(){
    return delegate.fold(
      (_) -> null,
      (e) -> e
    );
  }
  override public function get_result(){
    return delegate.fold(
      (r) -> r,
      (_) -> null
    );
  }
  override public function get_loaded(){
    return true;
  }
  override public function pursue(){}
}  