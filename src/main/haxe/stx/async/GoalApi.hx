package stx.async;

interface GoalApi<E>{
  public function pursue():Void;
  public function escape():Void;

  public var loaded(get,null):Bool;
  private function get_loaded():Bool;

  public var defect(get,null):Null<E>;
  private function get_defect():Null<E>;

  public var status(get,null):GoalStatus;
  private function get_status():GoalStatus;
}