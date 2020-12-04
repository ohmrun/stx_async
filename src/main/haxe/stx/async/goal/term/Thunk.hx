package stx.async.goal.term;

class Thunk extends Direct{
  var thunk : Void -> GoalStatus;

  public function new(thunk,?pos:Pos){
    super(pos);
    this.thunk = thunk;
  }
  override public function pursue(){
    this.status = thunk();
  }
  override public function update(){

  }
  override public function escape(){

  }
  override public function toString(){
    return 'goal.Thunk[$id ${get_status().toString()}]';
  }
}