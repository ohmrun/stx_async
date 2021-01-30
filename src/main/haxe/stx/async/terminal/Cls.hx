package stx.async.terminal;

private class TermTerm extends stx.async.work.term.Unit{
  override public function toString(){ return 'UNIT'; }
}
class Cls<R,E> implements Api<R,E> extends stx.async.goal.term.Direct{
  private var handles    : Array<Task<Dynamic,Any>>;
  public var dependent   : stx.async.task.term.Many<Dynamic,Any>;

  private function new(?pos:Pos){
    super(pos);    
    this.set_status(Pending);
    this.handles    = [];
    this.dependent  = new stx.async.task.term.Many(handles,pos);
    this.id         = Counter.next();
  }
  private function resolve(receiver:Receiver<R,E>,?pos:Pos):Receiver<R,E>{
    //__.log()('${this.identifier().name} resolve $receiver');
    var task                  = Task.After(receiver.prj(),this.toWork(),pos);
    return Receiver.lift(task.toTaskApi());
  }
  public inline function issue(res:Outcome<R,Defect<E>>,?pos:Pos):Receiver<R,E>{
    return resolve(res.fold(value.bind(_,pos),error.bind(_,pos)));
  }
  public inline function value(r:R,?pos:Pos):Receiver<R,E>{
    return resolve(Receiver.lift(Task.Pure(r,pos)),pos);
  }
  public inline function error(e:Defect<E>,?pos:Pos):Receiver<R,E>{
    return resolve(Receiver.lift(Task.Fail(e,pos)),pos);
  } 
  public inline function later(ft:Future<Outcome<R,Defect<E>>>,?pos:Pos):Receiver<R,E>{
    return resolve(Receiver.lift(Task.FutureOutcome(ft,pos)),pos);
  }                    
  public inline function lense(t:Task<R,E>,?pos:Pos):Receiver<R,E>{
    return resolve(Receiver.lift(t),pos);
  }                     
  //abstract
  //resolve                   
  private function release<RR,EE>(term:Terminal<RR,EE>,?pos:Pos):Terminal<RR,EE>{
    var next                = new stx.async.terminal.term.Release(term,this.toWork(),pos);
    //var this_id = this.get_id();
    //var that_id = term.get_id();
    this.handles.push(term.toTask());
    ////__.log()(next);
    return next;
  }

  public function pause(work:stx.async.Work,?pos:Pos):Terminal<R,E>{
    return release(new stx.async.terminal.term.Pause(work,pos),pos);
  }                                
  public function inner<RR,EE>(join:Outcome<RR,Array<EE>> -> Void,?pos:Pos):Terminal<RR,EE>{
    return release(new Handler(join,pos),pos);
  } 
  public function joint<RR,EE>(joiner:Outcome<RR,Defect<EE>> -> Work,?pos:Pos):Terminal<RR,EE>{
    return release(new Joint(joiner,pos),pos);
  }
  
  public inline function toTerminalApi():Api<R,E> return this;
  public inline function toTask():Task<R,E> return Task.lift(new stx.async.work.term.Goal(this.toGoalApi()));

  public function toString(){ 
    return '${this.identifier().name}:$id[${get_status()}]${ident()} [dependent: $dependent]'; 
  }

  public function ident(){
    return '(${pos.lift()})';
  }

  public function get_result():Null<R>{
    return throw "Terminal has no result";
  }
  public function get_defect():Defect<E>{
    return dependent.get_defect().entype();
  } 
  public function pursue(){
    __.log()('terminal.Cls.pursue ${dependent.get_status().toString()}');
    this.dependent.pursue();
    var dep_status = dependent.get_status();
    __.log()('$id dep_status:$dep_status');
    this.set_status(dep_status);
    var this_status = this.get_status();
    __.log()('$id this_status:$this_status');
    __.log()('${this.get_status()} ${dependent.get_status()}');
  }
  public function escape(){
    this.dependent.escape();
  } 
  public function update(){
    this.dependent.update();
  }
  override public function get_signal(){
    return dependent.signal;
  }
  public function toWork(?pos:Pos):Work{
    return Work.lift(new stx.async.work.term.Goal(this.toGoalApi(),pos));
  }
}