package stx.async.goal.term;

class Delegated extends Delegate{
  override public function get_id(){
    return this.delegate.get_id();
  }
  public function new(delegate:Goal,?pos:Pos){
    super(pos);
    this.delegate = delegate;
  }
  public var delegate(default,default):Goal;

  override public function get_loaded():Bool{
    return this.delegate.get_loaded();
  }
  override public function get_status():GoalStatus{
    return this.delegate.get_status();
  }
  override public function pursue(){
    this.delegate.pursue();
  }
  override public function escape(){
    this.delegate.escape();
  }
  override public function update(){
    this.delegate.update();
  }
  override public function toString(){
    return this.delegate == null ? "?" : this.delegate.toString();
  }
}