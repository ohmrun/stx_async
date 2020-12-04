package stx.async.terminal.term;

class Logging<R,E> implements Api<R,E> extends Delegate<R,E>{
  
  public function new(term:Terminal<R,E>,?pos:Pos){
    super(term,pos);
  }
  override public inline function issue(res:Outcome<R,Defect<E>>,?pos:Pos):Receiver<R,E>{
    ////__.log().debug('issue: $res on ${ident()}');
    return term.issue(res,pos);
  }
  override public inline function value(r:R,?pos:Pos):Receiver<R,E>{
    ////__.log().debug('value: $r on ${ident()}');
    return term.value(r,pos);
  }
  override public inline function error(e:Defect<E>,?pos:Pos):Receiver<R,E>{
    ////__.log().debug('error: $e on ${ident()}');
    return term.error(e,pos);
  }
  
  override public inline function later(ft:Future<Outcome<R,Defect<E>>>,?pos:Pos):Receiver<R,E>{
    ////__.log().debug('later prepped on ${ident()}');
    ft.handle(
      (_) -> {
        ////__.log().debug('later called on ${ident()}');
      }
    );
    return term.later(ft,pos);
  }
  override public inline function lense(t:Task<R,E>,?pos:Pos):Receiver<R,E>{
    ////__.log().debug('lense on ${ident()} for $t');
    return term.lense(t,pos);
  }



  override public inline function inner<RR,EE>(join:Outcome<RR,Array<EE>> -> Void,?pos:Pos):Terminal<RR,EE>{
    ////__.log().debug('inner on ${ident()}');
    return term.inner(join,pos);
  }
  override public inline function joint<RR,EE>(joiner:Outcome<RR,Defect<EE>> -> Work,?pos:Pos):Terminal<RR,EE>{
    ////__.log().debug('joint prepped on  ${ident()}');
    return term.joint(
      (outcome) -> {
        ////__.log().debug('joint called on  ${ident()}');
        return joiner(outcome);
      }
    ,pos);
  }
  override public inline function pause(work:Work,?pos:Pos):Terminal<R,E>{
    ////__.log().debug('pause on ${ident()} by $work');
    return term.pause(work,pos);
  }
  override public inline function toTerminalApi(){
    return this;
  }
  public function ident(){
    return 'id:${get_id()}(${pos.lift().toString_name_method_line()})';
  }
  override public function toWork(?pos:Pos){
    return this.term.toWork(pos);
  }
  override public function toGoalApi(){
    return this;
  }
}