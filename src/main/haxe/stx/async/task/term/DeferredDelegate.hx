package stx.async.task.term;

class DeferredDelegate<R,E> extends Delegate<R,E>{
  
  override public function get_status():GoalStatus{
    return if(delegate == null){
      Pending;
    }else{
      delegate.get_status();
    }
  }
  override public function pursue(){
    if(delegate != null){
      super.pursue();
    }
  }
  public inline function is_defined(){
    return __.option(this.delegate).is_defined();
  }
  override public function toString(){
    return 'DDelegate(${this.delegate})';
  }
}