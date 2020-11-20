package stx.async;

@:using(stx.async.GoalStatus.GoalStatusLift)
enum abstract GoalStatus(Int) from Int{
  var Problem = -1; // There's a problem, escape

  var Pending = 0;  // Waiting to be called
  var Applied = 1;  // Known that the Task requires to be called only once

  var Working = 2;  // Something is occurring, don't drop, but don't call either
  var Waiting = 3;  // Requires an asyncronous break, will call back on .signal

  
  var Secured = 4; // Value available.
}
class GoalStatusLift{
  static public inline function is_partial<T,E>(self:GoalStatus):Bool{
    return switch(self){
      case Pending | Waiting | Working  : true;
      default                           : false;
    }
  }
  static public function toString(self:GoalStatus):String{
    return switch self {
      case Problem : "Problem";
      case Applied : "Applied";
      case Pending : 'Pending';
      case Working : "Working";
      case Waiting : "Waiting";
      case Secured : "Secured";
    }
  }
}