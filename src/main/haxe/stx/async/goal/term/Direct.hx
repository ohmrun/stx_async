package stx.async.goal.term;

abstract class Direct implements stx.async.goal.Api extends stx.async.tick.Abs{
  public function new(?pos:Pos){
    super(pos);
    this.status = Pending;
  }
  abstract public function pursue():Void;
  abstract public function escape():Void;

  public function get_loaded():Bool{
    return this.status == Secured;
  }
  
  @:isVar public var status(get,set):GoalStatus;
  public function get_status():GoalStatus return this.status;
  public function set_status(status:GoalStatus):GoalStatus{ 
    #if debug
    __.assert().exists(status);
    #end
    return this.status = status; 
  }


  public function toGoalApi():GoalApi{
    return this;
  }
  @:isVar public var id(get,null):Int;
  override public function get_id(){
    return this.id;
  }
}