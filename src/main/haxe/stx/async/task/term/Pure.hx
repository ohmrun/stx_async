package stx.async.task.term;

class Pure<T,E> extends TaskCls<T,E>{
  public function new(result){
    super();
    __.assert().exists(result);
    this.loaded = true;
    this.result = result;
    this.status = Secured;
  }
  override public function toString(){
    return 'Pure(${status.toString()})';
  }
}
