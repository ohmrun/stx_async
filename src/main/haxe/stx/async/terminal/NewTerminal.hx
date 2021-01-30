package stx.async.terminal;

interface GoalTreeApi extends stx.async.goal.Api{
  public function get_root():Goal;
}
abstract class GoalTreeDirect extends stx.async.goal.term.Direct implements GoalTreeApi{
  private var parent : GoalTreeApi;
  public function get_root(){
    return (parent == null) ? this : parent.get_root();
  }
}
abstract class TerminalTaskCls<R,E> implements stx.async.task.Api<R,E>{
  abstract public function get_defect():Defect<E>;
  abstract public function get_result():Null<R>;
  

  public function toWork(?pos:Pos):Work{
    return this;
  }
  public function toTaskApi():TaskApi<R,E>{
    return this;
  }

  public function toString():String{
    return '';
  }
}
abstract class Arriliko<I,O,E>{
  abstract public function defer(i:I,cont:Resolver<O,E>):Order;
}
class ArrilikoThen<I,Oi,Oii,E> extends Arriliko<I,Oii,E>{
  var lhs : Arriliko<I,Oi,E>;
  var rhs : Arriliko<Oi,Oii,E>;
  
  public function new(lhs,rhs){
    this.lhs = lhs;
    this.rhs = rhs;
  }
  public function defer(i:I,cont:Resolver<Oii,E>){
    return lhs.defer(
      i,
      cont.contain(
        (oc:Outcome<Oi,Defect<E>>) -> oc.fold(
          ok -> rhs.defer(ok,cont),
          no -> cont.resolve(__.failure(no)).serve()
        )
      )
    );
  }
}
class ArrilikoBoth<Ii,Iii,Oi,Oii,E> extends Arriliko<Couple<Ii,Iii>,Couple<Oi,Oii>,E>{
  
  var lhs : Arriliko<Ii,Oi,E>;
  var rhs : Arriliko<Iii,Oii,E>;

  public function new(lhs,rhs){
    this.lhs = lhs;
    this.rhs = rhs;
  }
  public function defer(i:Couple<Ii,Iii>,cont:Resolver<Couple<Oi,Oii>,E>){
    return i.decouple(
      (l,r) -> {
        var lhs = None;
        var rhs = None;
        var handler = () -> {
          switch([lhs,rhs]){
            case [None,_]                             :
            case [_,None]                             : 
            case [Some(Failure(l)),Some(Failure(r))]  : cont.resolve(__.failure(l.concat(r)));
            case [Some(Failure(l)),Some(Success(_))]  : cont.resolve(__.failure(l)); 
            case [Some(Success(_)),Some(Failure(r))]  : cont.resolve(__.failure(r));            
            case [Some(Success(l)),Some(Success(r))]  : cont.resolve(__.success(__.couple(l,r))); 
          }
        }
        var a = cont.contain(
          oc
        );
        //var b = cont.detach();

        //var l = lhs.defer(l,a);
        //var r = rhs.defer(r,b);
        return Order.unit();
      }
    );
  }
}
abstract Order(Null<Goal>) from Null<Goal>{
  static public inline function unit():Order return null;
  static public inline function lift(self:Goal):Order return self;
  public function prj():Goal return this;
}
class Resolver<R,E> extends GoalTreeDirect{
  public var resolved(default,null):Bool;

  var goals   : stx.async.goal.term.Par;
  var handle  : Array<Goal>;

  static public function unit<R,E>() return new Resolver();
  
  public function new(?pos:Pos){
    this.resolved = false;
    this.handle   = [];
    this.goals    = new stx.async.goal.term.Par(this.handle);
    super(pos);
  }
  public function resolve(v:Outcome<R,Defect<E>>):Resolved<R,E>{
    if(!resolved){resolved = true;}

    return new Resolved(v,this);
  }
  public function detach<RR,EE>(joint):Order{
    var result = new Detached(this,joint,pos);
    handle.push(result);
    return Order.lift(this.toGoal());
  }
  public function contain<RR,EE>(joint):Resolver<RR,EE>{
    var result = new Contained(this,joint,pos);
    handle.push(result);
    return result;
  }
  public function pursue(){this.goals.pursue(); }
  public function escape(){this.goals.escape(); }
  public function update(){this.goals.update(); }

  override public function get_status(){  return this.goals.get_status(); }
  override public function get_loaded(){  return this.goals.get_loaded(); }

  public function toGoal():Goal{
    return this;
  }
  public function toString(){
    return this.goals.toString();
  }
}
// class Zip<Ri,Rii,E> extends Resolver<Couple<Ri,Rii>,E>>{
//   var lhs : Resolver<Ri,E>;
//   var rhs : Resolver<Rii,E>;

//   public function new(lhs:Resolver<Ri,E>,rhs:Resolver<Rii,EE>,?pos:Pos){
//     super(pos);
//     this.lhs = lhs;
//     this.rhs = rhs;
//   }
// }
class Resolved<R,E> extends stx.async.task.term.Stamp<R,E> implements GoalTreeApi{
  public var parent(default,null):GoalTreeApi;
  
  public function new(result,parent,?pos){
    super(result,pos);
    this.parent = parent;
  }
  public function serve():Order{
    return Order.lift(this.toGoal());
  }
  override public function pursue(){      
    this.parent.pursue(); 
  }
  override public function escape(){      
    this.parent.escape(); 
  }
  override public function get_status(){  
    return this.parent.get_status(); 
  }
  override public function get_loaded(){  
    return this.parent.get_loaded(); 
  }
  public function toGoal():Goal{
    return this;
  }
  public function get_root(){
    return parent.get_root();
  }
  //public function 
}
class Detached<R,E> extends Resolver<R,E>{
  public var combined(default,null) : Bool = false;
  
  dynamic function joint(resolver:Resolver<R,E>):Order{
    return Order.unit();
  }
  public function new(parent,joint,?pos:Pos){
    super(pos);
    this.parent     = parent;
    this.combined   = false;
    this.joint      = joint;
  }
  override public function pursue(){      
    if(!combined){
      combined = true;
      this.handle.push(this.joint(this).prj());
    }else{
      this.parent.pursue(); 
    }
  }
  override public function escape(){      
    super.escape();
    parent.escape(); 
  }
}
class Contained<R,E> extends Resolver<R,E>{ 
  public var combined(default,null):Bool;

  public function new(parent:GoalTreeApi,joint,?pos:Pos){
    super(pos);
    this.parent     = parent;
    this.combined   = false;
    this.joint      = joint;
  }
  dynamic function joint(outcome:Outcome<R,Defect<E>>):Order{
    return Order.unit();
  }
  override public function resolve(v:Outcome<R,Defect<E>>):Resolved<R,E>{
    this.handle.push(this.joint(v).prj());
    return super.resolve(v);
  }
  override public function pursue(){      
    parent.pursue(); 
  }
  override public function escape(){      
    parent.escape(); 
  }
  override public function get_status(){  
    return parent.get_status(); 
  }
}