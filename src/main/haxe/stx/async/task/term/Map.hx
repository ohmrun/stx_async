package stx.async.task.term;

class Map<Ri,Rii,E> extends stx.async.task.Direct<Rii,E>{
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
    return this.delegate.get_defect();
  }
  override public function get_status():GoalStatus{
    return this.delegate.get_status();
  }
  public function pursue(){
    this.delegate.pursue();
  }
  override public function escape(){
    this.delegate.pursue();
  }
  override public function update(){
    this.delegate.update();
  }
  override public function get_result(){
    return transform(this.delegate.get_result());
  }
}