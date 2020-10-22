package stx.async.task.term;

class Pure<T,E> extends TaskCls<T,E>{
  public function new(result){
    super();
    this.loaded = true;
    this.result = result;
  }
}
