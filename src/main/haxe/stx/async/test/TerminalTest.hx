package stx.async.test;

typedef Arw<T,Ti> = T -> Terminal<Ti,Noise> -> Work;

class TerminalTest extends utest.Test{
  private static function get_terminal<R,E>():Terminal<R,E>{
    return @:privateAccess new Terminal();
  }
  public function test_terminal_cascade(){
    var t = get_terminal();
    var n = t.joint(
          (oc) -> {
            //__.log()(oc);
            return Work.ZERO;
          }
        ).joint(
          (oc) -> {
            //__.log()(oc);
            return Work.ZERO;
          }
        );

    var w = n.value(1).serve();
        w.crunch();
  }
  public function _test(){
    var terminal  = get_terminal();
    var f         = Future.trigger();
        f.asFuture().handle(
          (i) -> same(__.success(2),i)
        );
    var a         = terminal.later(f);

    var b         = terminal.inner(
      (oc) -> {
        //__.log()('trigger: $oc');
        f.trigger(__.log().close().through()(oc.map(i -> ++i)));
      }
    );
    var next      = a.after(b.value(1).serve()); 
        next.crunch();
  }
  public function _test_joint(){
    var terminal  = get_terminal();
    var methodII  = function (i:String,cont:Terminal<String,Noise>):Work{
      return cont.value(__.log().through()('hello: $i')).serve();
    }
    var methodI   = function(i:Int,cont:Terminal<String,Noise>):Work{
      var joint = cont.joint(
        (oc:stx.Outcome<String,Defect<Noise>>) -> {
          //__.log().debug(oc);
          return oc.fold(
            (ok) -> methodII('$i',cont),
            (no) -> Work.Stamp(__.failure(no))
          );
        }
      );
      return joint.value('$i').serve();
    }
    var methodIII = fn(__.log().through());
    var methodIV  = fn(
      __.passthrough((x) -> {
        utest.Assert.pass();
      })
    );
    var arw       = then(then(methodI,methodIII),methodIV);
        arw(1,terminal).crunch();
  }
  static function fn<Ti,Tii>(fn:Ti->Tii):Arw<Ti,Tii>{
    return (tI:Ti,cont:Terminal<Tii,Noise>) -> {
      return cont.value(fn(tI)).serve();
    }
  }
  static function then<Ti,Tii,Tiii>(lhs:Arw<Ti,Tii>,rhs:Arw<Tii,Tiii>):Arw<Ti,Tiii>{
    return (tI:Ti,cont:Terminal<Tiii,Noise>) -> {
      var joint = cont.joint(
        (outcome:stx.Outcome<Tii,Defect<Noise>>) -> outcome.fold(
          (ok) -> rhs(ok,cont),
          (no) -> Work.Stamp(__.failure(no))
        )
      );
      return lhs(tI,joint);
    }
  }
} 