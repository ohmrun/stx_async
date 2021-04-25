package stx.async.test;

class GoalSeqTest extends TestCase{
  public function test_fastpath(){
    var goal_seq = Goal.Seq(
      Goal.Thunk(
        () -> Secured
      ),
      Goal.Thunk(
        () -> Secured
      )
    );
    this.equals(false,@:privateAccess goal_seq.sel);
        goal_seq.pursue();
    this.equals(Secured,@:privateAccess goal_seq.lhs.get_status());
        goal_seq.pursue();
    this.equals(true,@:privateAccess goal_seq.sel);
  }
}