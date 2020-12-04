package stx.async.goal;

typedef Def = stx.async.tick.Def & {
  public function pursue():Void;
  public function escape():Void;

  public function get_loaded():Bool;
  public function get_status():GoalStatus;
}