package stx.async.test;

class NewTerminalTest extends utest.Test{
  private function get_resolver<R,E>():Resolver<R,E>{ return @:privateAccess Resolver.unit(); }

  public function test(){
    var resolver        = get_resolver();
    var detached        = resolver.detach(
      (resolve:Resolver<Int,Dynamic>) -> {
    
        var a = resolver.contain(
          (outcome) -> Order.unit()
        );
        
        return resolve.resolve(__.success(1)).serve();
      }
    );
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