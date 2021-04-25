package stx.async.test;

class GoalSeqTest extends TestCase{
  public function test(){
    var goal_seq = Goal.Seq(
      Goal.Thunk(
        () -> Secured
      ),
      Goal.Thunk(
        () -> Secured
      )
    );
    same(false,@:privateAccess goal_seq.sel);
    goal_seq.pursue();
    same(Secured,@:privateAccess goal_seq.lhs.get_status());
    goal_seq.pursue();
    same(true,@:privateAccess goal_seq.sel);
    //__.`()(goal_seq.get_status());
    same(Secured,goal_seq.get_status());
  }
}