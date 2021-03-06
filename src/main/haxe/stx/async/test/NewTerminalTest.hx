package stx.async.test;

import stx.async.terminal.NewTerminal;
class NewTerminalTest extends TestCase{
  private function get_resolver<R,E>():Resolver<R,E>{ return @:privateAccess Resolver.unit(); }

  public function test(async:Async){
    var resolver        = get_resolver();
    var detached        = resolver.detach(
      (resolve:Resolver<Int,Dynamic>) -> {
    
        var a = resolver.contain(
          (outcome) -> Order.unit()
        );
        
        return resolve.resolve(__.success(1)).serve();
      }
    );
    Loop.ZERO.add(Work.fromGoal(detached.toGoal()));
    // );
    // var contained       = resolver.contain(
    //   (outcome:Outcome<String,Defect<Dynamic>) -> outcome.fold(
    //     ok -> ...
    //   )
    // )
    // var p : Dynamic = {};
    //     p.detach(
    //       (cont:Resolver<Int,Dynamic>) -> cont.resolve(1).serve()
    //     );
    //     p.contain(
    //       (cont:Outcome<Int,Defect<Dynamic>>) -> {

    //       }
    //     );

    //var issued_detached = detached.issue(__.success(1));
    //$type(issued_detached);
  }
}