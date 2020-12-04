package stx.async.terminal.term;


class Release<R,E> extends Delegate<R,E>{
  var work : Work;

  public function new(delegate:Terminal<R,E>,work:Work,?pos:Pos){
    //__.log()('Release.new');
    super(delegate,pos);
    this.work = work;
  }
  override public function issue(res:Outcome<R,Defect<E>>,?pos:Pos):Receiver<R,E>{
    return resolve(super.issue(res,pos),pos);
  }
  override public function value(r:R,?pos:Pos):Receiver<R,E>{
    return resolve(super.value(r,pos),pos);
  }
  override public function error(err:Defect<E>,?pos:Pos):Receiver<R,E>{
    return resolve(super.error(err,pos),pos);
  }
  @:access(stx.async) override private function resolve(receiver:Receiver<R,E>,?pos:Pos):Receiver<R,E>{
    //__.log().debug('resolve $receiver on $this');
    return Receiver.lift(
      Task.After(
        @:privateAccess receiver.prj(),
        work,
        pos
      ).toTaskApi()
    );
  }
  override public function pursue(){
    super.pursue();
  }
} 