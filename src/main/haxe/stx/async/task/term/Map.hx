package stx.async.task.term;

class Map<Ri,Rii,E> extends TaskCls<Rii,E>{
  public var delegate(default,null):Task<Ri,E>;
  public var transform(default,null):Ri->Rii;

  public function new(delegate,transform){
    super();
    this.delegate   = delegate;
    this.transform  = transform;
  }
  override public function get_signal():Signal<Noise>{
    return this.delegate.signal;
  }
  override public function get_defect():Defect<E>{
    return this.delegate.defect;
  }
  override public function get_status():GoalStatus{
    return this.delegate.status;
  }
  override public function pursue(){
    this.delegate.pursue();
    if(this.delegate.loaded){
      this.result = transform(this.delegate.result);
    }
  }
  override public function escape(){
    this.delegate.escape();
  }
}