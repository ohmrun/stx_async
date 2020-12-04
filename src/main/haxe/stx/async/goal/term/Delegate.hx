package stx.async.goal.term;

abstract class Delegate implements Api extends stx.async.tick.Abs{

  abstract public function get_loaded():Bool;

  abstract public function get_status():GoalStatus;

  public function toGoalApi():GoalApi return this;

  abstract public function toString():String;
}