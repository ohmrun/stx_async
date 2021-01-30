package stx.async.terminal.term;

class Joint<R,E> extends Cls<R,E>{

  dynamic function joiner(outcome:Outcome<R,Defect<E>>):Work{ return Work.Unit(); }

  var called : Bool;

  public function new(joiner:Outcome<R,Defect<E>>->Work,?pos:Pos){
    super(pos);
    //__.log()('Joint.new $id');
    this.called   = false;
    this.joiner   = joiner;   
  }
  // private function release<RR,EE>(term:Terminal<RR,EE>,?pos:Pos):Terminal<RR,EE>{
  //   return new stx.async.terminal.Task(term,joining,pos);
  // }
  @:access(stx.async) override private inline function resolve(receiver:Receiver<R,E>,?pos:Pos):Receiver<R,E>{
    __.log().debug('resolve $receiver on $this');
    return super.resolve(Receiver.lift(
      new stx.async.terminal.Task(receiver.prj(),joining,pos)
    ));
  } 
  /**
    Could be called mmultiple ways and times depending on how the join is constructed.
  **/

  private function joining(outcome:Outcome<R,Defect<E>>):Work{
    return if(!called){
      called = true;
      var result = joiner(outcome);
      //__.log()('JOINT RETURNS $result');
      result;
    }else{
      //throw 'rejoin';
      Work.Unit();
    }
  }
  override public function get_status(){
    __.log().trace((ctr) -> ctr.self(this, (x) -> '${x.id} ${x.called} status:${x.__status.toString()}'));
    return called ? super.get_status() : Pending;
  }
  override public function pursue(){
    super.pursue();
  }
}