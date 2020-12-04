package stx.async.task;

abstract class Abs<T,E> implements Api<T,E> extends stx.async.goal.term.Direct{
  
  public function new(?pos:Pos){
    super(pos);
  }
  public var result(get,set):Null<T>;

  abstract public function get_result():Null<T>;
  abstract public function set_result(v:Null<T>):Null<T>;
  
  public var defect(get,set):Defect<E>;

  abstract public function get_defect():Defect<E>;
  abstract public function set_defect(v:Defect<E>):Defect<E>;
  // return this.defect == null ? this.defect = Defect.unit() : this.defect;
  
  public inline function toTaskApi():TaskApi<T,E>{
    return (this:TaskApi<T,E>);
  }
  public inline function toWork(?pos:Pos):Work{
    //return Work.lift(Task.At(this.toTaskApi(),pos));
    return Work.lift(this.toTaskApi());
  }

  override public function get_loaded(){
    return this.status == Secured;
  }

  public function toString(){
    return Util.toString(this);
  }
}
