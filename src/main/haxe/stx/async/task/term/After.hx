package stx.async.task.term;
class After<R,E> extends Filter<Couple<R,Any>,R,E>{ 
  override function filter(tp:Couple<R,Any>):R{
    return tp.fst();
  }
  public function new(next:Task<R,E>,work:Work,?pos:Pos){
    super(Task.lift(new Seq(next,work.latch(),pos).toTaskApi()),pos);
  }
}