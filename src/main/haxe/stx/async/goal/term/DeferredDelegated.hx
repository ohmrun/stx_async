package stx.async.goal.term;
 
class DeferredDelegated extends Delegated{
  override public function get_loaded():Bool{
    return __.option(this.delegate).is_defined().if_else(
      () -> this.delegate.get_loaded(),
      () -> false
    );
  }
  override public function get_status(){
    return __.option(this.delegate).is_defined().if_else(
      () -> this.delegate.get_status(),
      () -> Pending
    );
  }
  override public function pursue(){
    if(this.delegate!=null){
      this.delegate.pursue();
    }
  }
  override public function escape(){
    if(this.delegate!=null){
      this.delegate.escape();
    }
  }
  override public function update(){
    if(this.delegate!=null){
      this.delegate.update();
    } 
  }
}