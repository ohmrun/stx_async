package stx.async;

enum abstract GoalStatus(Int) from Int{
  var Pending = 0;
  var Working = 1;
  var Waiting = 2;
  var Secured = 3;

  var Problem = -1;

  var Applied = 4;
}