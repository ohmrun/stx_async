package stx.async.goal.term;

class Delegated extends Delegate{
  public function get_id(){
    return this.delegate.get_id();
  }
  public function new(delegate:Goal,?pos:Pos){
    super(pos);
    this.delegate = delegate;
  }
  public var delegate(default,default):Goal;

  public function get_loaded():Bool{
    return this.delegate.get_loaded();
  }
  public function get_status():GoalStatus{
    return this.delegate.get_status();
  }
  public function pursue(){
    this.delegate.pursue();
  }
  public function escape(){
    this.delegate.escape();
  }
  public function update(){
    this.delegate.update();
  }
  public function toString(){
    return this.delegate == null ? "?" : this.delegate.toString();
  }
}