package stx.async.task.term;

abstract class Delegate<R,E> extends stx.async.task.Delegate<R,E>{
  @:isVar public var delegate(get,set):Task<R,E>;
  public function get_delegate(){
    return delegate;
  }
  public function set_delegate(delegate:Task<R,E>){
    return this.delegate = delegate;
  }
  public function new(delegate:Task<R,E>,?pos:Pos){
    super(pos);
    this.delegate   = delegate;
  }
  override public function get_signal():Signal<Noise>{
    this.delegate.signal.handle(
      (_) -> this.trigger.trigger(Noise)
    );
    return super.get_signal();
  }
  public function get_defect():Defect<E>{
    return this.delegate.get_defect();
  }
  public function get_result():Null<R>{
    return this.delegate.get_result();
  }
  abstract public function get_status():GoalStatus;

  public function pursue(){
    if(!get_loaded()){
      this.delegate.pursue();
    }
  }
  public function escape(){
    this.delegate.escape();
  }
  public function update(){
    this.delegate.update();
  }
  public function get_loaded(){
    return this.delegate.get_loaded();
  }
  override public function toString(){
    return Util.toString(this);
  }
  public function get_id(){
    return this.delegate.get_id();
  }
}