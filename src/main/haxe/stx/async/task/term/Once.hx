package stx.async.task.term;

class Once<R,E> extends TaskCls<R,E>{
  override public function pursue(){
    this.status = Secured;
  }
}