package stx.async.goal.term;

abstract class Direct implements stx.async.goal.Api extends stx.async.tick.Abs{
  public function new(?pos:Pos){
    super(pos);
    this.set_status(Pending);
  }
  abstract public function pursue():Void;
  abstract public function escape():Void;

  public inline function get_loaded():Bool{
    return this.get_status() == Secured;
  }
  
  private var __status:GoalStatus;
  public function get_status():GoalStatus {
    //__.log()('GET ${this.definition().identifier()} status:$__status');
    return this.__status;
  }
  public function set_status(v:GoalStatus):GoalStatus{ 
    //trace('SET $id to $v on ${this.identifier()}');
    this.__status = v; 
    return __status;
  }


  public function toGoalApi():GoalApi{
    return this;
  }
  @:isVar public var id(get,default):Int;
   public function get_id(){
    return this.id;
  }
}