package stx.async.test;

typedef Arw<T,Ti> = T -> Terminal<Ti,Noise> -> Work;

class TerminalTest extends utest.Test{
  private static function get_terminal<R,E>():Terminal<R,E>{
    return @:privateAccess Terminal.ZERO;
  }
  public function _test_shim(){
    var term    = get_terminal();
    var result  = term.value(1);
    var shim    = Work.Shim(term.toTask());
    same(Secured,shim.get_status());
  }
  public function _test_release(){
    var term      = get_terminal();
    var work      = Work.unit();
    var release   = new stx.async.terminal.term.Release(term,work);
    trace(release);
    var value     = release.value(1);
    var receiver  = value.serve();
    trace(receiver);
          receiver.pursue();
          receiver.pursue();
          receiver.pursue();
    trace(receiver);
  }
  public function _test_terminal_task(){
    var term      = get_terminal();
    var task      = new stx.async.terminal.Task(
      Task.Pure(1),
      (oc) -> {
        trace("RRERER");
        return Work.Unit();
      }
    );
    trace(task);
          task.pursue();
          task.pursue();
    trace(task);
  }
  public function _test_cls(){
    var term = get_terminal().value(1);
    __.log()(term);
    var task      = term.prj();
        task.pursue();
    __.log()(task);
  }
  public function test_one(){
    var term = get_terminal();
    __.log()("________________________");
    var rest = term.joint(
      (oc) -> {
        __.log()('USER JOIN CLOSURE: $oc');
        return term.value("HELLO").serve();
      } 
    );
    __.log()("________________________");
    __.log()(rest);
    var task = rest.value(1);
    __.log()("________________________");
    var work = task.serve();
    trace(work);
      trace("PURSUE 1");
      work.pursue();
      __.log()("________________________");
      trace(work);
      trace('PURSUE 2 ');
      work.pursue();
      // work.pursue();
      // work.pursue();
      // work.pursue();
      __.log()("________________________");
      trace(work);
      trace('PURSUE 3 ');
      work.pursue();
      work.pursue();
      work.pursue();
      //work.pursue();
      trace(work);
    //trace(term);
    //trace("PURSUE");
    //     work.pursue();
    // trace("PURSUE");
    //     work.pursue();
    // var done = rest.value(1);
    // trace(done);
    // var work = done.serve();
    // trace("PURSUE");
    //     work.pursue();
    // trace("PURSUE");
    //     work.pursue();
    // trace("PURSUE");
    //     work.pursue();
    // trace("PURSUE");
    //     work.pursue();
    equals(0,work.get_status());
  }
  public function _test_terminal_cascade(){
    var v     = None;
    var t     = get_terminal();
    var task  = Task.Handler(
      Task.Pure(100),
      (x) -> {
        v = __.option(x.fudge());
      }
    );
    var n = t.joint(
          (oc) -> {
            same(__.success(1),oc);
            __.log().debug('FIRST: $oc');
            return t.value(100).serve();
          }
        ).joint(
          (oc) -> {
            __.log().debug('SECOND: $oc');
            same(__.success(100),oc);
            return t.value(60).serve();
          }
        );

    var w = n.value(1).serve();
    var c = w;
        trace(c);
        c.pursue();
        trace("_____________________");
        c.pursue();
        trace(c);
        trace("_____________________");
        c.pursue();
        trace(c);
        // c.pursue();
        // c.pursue();
        // c.pursue();
        // c.pursue();
        // c.pursue();
        //trace(c);
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