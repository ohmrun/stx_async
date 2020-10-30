package stx.async;

typedef GoalDef<E> = {
  public function pursue():Void;
  public function escape():Void;

  public var loaded(get,null):Bool;
  public function get_loaded():Bool;

  public var defect(get,null):Defect<E>;
  public function get_defect():Defect<E>;

  public var status(get,null):GoalStatus;
  public function get_status():GoalStatus;
}