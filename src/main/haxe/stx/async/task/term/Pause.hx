package stx.async.task.term;

class Pause<R,E> extends Filter<Couple<Any,R>,R,E>{
  function filter(tp:Couple<Any,R>):R{
    return tp.snd();
  }
  public function new(work:Work,next:Task<R,E>,?pos:Pos){
    super(Task.Seq(work.latch(),next),pos);
  }
}