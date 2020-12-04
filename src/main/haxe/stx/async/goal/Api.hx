package stx.async.goal;

interface Api extends stx.async.tick.Api{

  public function get_loaded():Bool;

  public function get_status():GoalStatus;

  @:isVar public var signal(get,null):tink.core.Signal<Noise>;
  public function get_signal():Signal<Noise>;
  
  public function toGoalApi():Api;

  public function toString():String;
}