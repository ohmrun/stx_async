package stx.async.terminal;

class Task<T,E> extends stx.async.goal.term.Seq implements stx.async.task.Api<T,E>{
  override public function get_status(){
    var result = super.get_status();
    ////__.log()(result.toString());
    return result;
  }
  var delegate                    : stx.async.Task<T,E>;
  var deferred                    : stx.async.goal.term.DeferredDelegated;
  @:isVar var work(get,set)       : Work;
  public function get_work(){
    return work;
  }
  public function set_work(v:Work){
    var goal = v.toGoalApi();
    this.deferred.delegate = goal;
    return work = v;
  }

  dynamic function joiner(outcome:Outcome<T,Defect<E>>):Work{
    return Work.Unit();
  }
  public function new(delegate:stx.async.Task<T,E>,joiner:Outcome<T,Defect<E>>->Work,?pos:Pos){
    this.delegate = delegate;
    this.deferred = new stx.async.goal.term.DeferredDelegated(null);
    super(delegate.toGoalApi(),deferred.toGoalApi(),pos);
    this.joiner   = joiner;
  }
  function join(oc:Outcome<T,Defect<E>>){
    //__.log()('JOINING: $work');
    this.work = oc.fold(
      ok -> {
        return joiner(__.success(ok));
      },
      no -> {
        return joiner(__.failure(no));
      }
    );
    //__.log()('JOINED: $work');
  }
  override inline public function pursue(){
    //__.log()('terminal.Task.pursue() $this');
    super.pursue();
    var lhs_status = lhs.get_status();
    ////__.log()('${get_id()} ${lhs_status}');
    if(this.work == null){
      switch(lhs_status){
        case Problem : 
          join(__.failure(delegate.get_defect()));
        case Pending : 
        case Applied : 
          delegate.get_defect().is_defined().if_else(
            () -> {
              join(__.failure(delegate.get_defect()));
            },
            () -> {
              join(__.success(delegate.get_result()));
            }
          );
        case Working :
        case Waiting : 
          this.delegate.signal.nextTime().handle(
            (_) -> {
              this.trigger.trigger(Noise);
            }
          );
        case Secured : 
           join(__.success(this.delegate.get_result()));
          ////__.log()(this.work);
      }
    }
  }
  public function get_defect():Defect<E>{
    var that = __.option(this.work).map(_ -> _.get_defect()).def(Defect.unit);
    return __.option(this.delegate.get_defect()).defv([]).concat(that.entype());
  }
  public function get_result():Null<T>{
    return this.delegate.get_result();
  }
  override public function toString(){
    var b = deferred.toString();
    return '${this.identifier().name}[${get_id()}:${get_status().toString()}]($delegate >>> $b)';
  }
  public function toTaskApi(){
    return this;
  }
  public function toWork(?pos:Pos){
    return this;
  }
}