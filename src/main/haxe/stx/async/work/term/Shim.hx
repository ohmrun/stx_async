package stx.async.work.term;

class Shim implements WorkApi{
  var task : Task<Dynamic,Dynamic>;
  public function new(task){
    this.task = task;
  }
  @:isVar public var id(get,null):String;
  public function get_id():String{
    return this.task.id;
  }


  public var loaded(get,null):Bool;
  public inline function get_loaded(){
    return this.status == Secured;
  }
  public inline function toWork():Work return Work.lift(this);
  public function toTaskApi():TaskApi<Any,Dynamic> return this;

  public var signal(get,null):tink.core.Signal<Noise>;
  public function get_signal():tink.core.Signal<Noise>{
    return this.task.signal;
  }
  public var defect(get,null):Defect<Dynamic>;
  public function get_defect():Defect<Dynamic>{
    return this.task.defect.elide();
  }
  public var result(get,null):Null<Any>;
  public function get_result():Null<Any>{
    return null;
  }
  public var status(get,null):GoalStatus;
  public function get_status():GoalStatus{
    return this.task.status;
  }
  public function pursue(){
    this.task.pursue();
  }
  public function escape(){
    this.task.escape();
  }
}