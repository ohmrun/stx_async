package stx.async.task.term;

class Pause<R,E> extends FlatMap<Any,R,E>{
  public function new(work:Work,next:Task<R,E>){
    var ft = Future.trigger();
    super(
      work.latch(),
      (_:Any) -> next  
    );
  }
}