package stx.async.task.term;

class Pause<R,E> extends FlatMap<Any,R,E>{
  public function new(work:Work,next:Task<R,E>){
    super(
      work.latch(),
      (_:Any) -> next  
    );
  }
  override public function toString(){
    var spr = super.toString();
    return 'Pause($spr)';
  }
}