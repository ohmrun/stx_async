package stx.async.work.term;

class Stamp extends TaskCls<Any,Dynamic>{
  var delegate : Outcome<Any,Defect<Dynamic>>;
  public inline function new(outcome:Outcome<Any,Defect<Dynamic>>){
    super();
    this.loaded   = true;
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
}  