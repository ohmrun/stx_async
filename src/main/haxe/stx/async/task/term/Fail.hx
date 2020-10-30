package stx.async.task.term;

class Fail<T,E> extends TaskCls<T,E>{
  public function new(defect:Array<E>){
    super();
    this.defect = defect;
    this.status = Problem;
  }
}