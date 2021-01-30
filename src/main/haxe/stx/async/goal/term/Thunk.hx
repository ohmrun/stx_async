package stx.async.goal.term;

class Thunk extends Direct{
  var thunk : Void -> GoalStatus;

  public function new(thunk,?pos:Pos){
    super(pos);
    this.thunk = thunk;
  }
  public function pursue(){
    this.set_status(thunk());
  }
  public function update(){

  }
  public function escape(){

  }
  public function toString(){
    return 'goal.Thunk[$id ${get_status().toString()}]';
  }
}