package stx.async.task.term;

class Fail<T,E> extends stx.async.task.Direct<T,E>{
  public function new(defect:Array<E>,?pos:Pos){
    super(pos);
    this.defect = defect;
    this.set_status(Problem);
  }
  public function pursue(){}
}