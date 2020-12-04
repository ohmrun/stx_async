package stx.async.task.term;

class Logging<R,E> extends stx.async.task.term.Delegate<R,E>{
  public var logging(default,null):stx.Log;
  public var showing(default,null):Task<R,E> -> String;

  public function new(delegate:Task<R,E>,?logging:stx.Log,?showing,?pos:Pos){
    super(delegate,pos);
    this.logging    = __.option(logging).def(() -> __.log());
    this.showing    = __.option(showing).defv((t:Task<R,E>) -> t.toString());
  }
  override inline public function pursue(){
    //__.log().debug(showing(delegate),__.here());
    this.delegate.pursue();
  }
  override inline public function escape(){
    this.delegate.escape();
  }
  override public function toString(){
    return return 'Logging(${this.delegate})';
  }
  override public inline function get_status(){
    return delegate.get_status();
  }
}