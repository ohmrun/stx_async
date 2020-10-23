package stx.async;

@:using(stx.async.GoalStatus.GoalStatusLift)
enum abstract GoalStatus(Int) from Int{
  var Problem = -1;
  var Pending = 0;
  var Working = 1;
  var Waiting = 2;

  var Applied = 3;
  var Secured = 4;
}
class GoalStatusLift{
  static public function toString(self:GoalStatus):String{
    return switch self {
      case Problem : "Problem";
      case Pending : 'Pending';
      case Working : "Working";
      case Waiting : "Waiting";
      case Applied : "Applied";
      case Secured : "Secured";
    }
  }
}