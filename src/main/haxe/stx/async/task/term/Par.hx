package stx.async.task.term;

class Par<T,Ti,E> extends stx.async.task.Direct<Couple<T,Ti>,E>{
  var lhs : TaskApi<T,E>;
  var rhs : TaskApi<Ti,E>;

  public function new(lhs:TaskApi<T,E>,rhs:TaskApi<Ti,E>,?pos:Pos){
    super(pos);
    this.lhs = lhs;
    this.rhs = rhs;
  }
  override public function pursue(){
    if(!defect.is_defined() && !get_loaded()){
      this.lhs.pursue();
      this.rhs.pursue();
      switch([this.lhs.get_status(),this.rhs.get_status()]){
        case [Applied,Applied] : 
          this.status = Secured;
          this.result = __.couple(lhs.get_result(),rhs.get_result());
        case [Problem,_] :
          this.defect = lhs.get_defect();
          this.status = Problem;
        case [_,Problem] :  
          this.defect = rhs.get_defect();
          this.status = Problem;
        case [Secured,Secured] : 
          this.status = Secured;
          this.result = __.couple(lhs.get_result(),rhs.get_result());
        case [Waiting,Waiting] : 
          this.status = Waiting;
          lhs.signal.nextTime().merge(
            rhs.signal.nextTime(),
            (_,_) -> Noise
          ).handle(
            (_) -> this.trigger.trigger(Noise)
          );
        case [Waiting,_] : 
          this.status = Waiting;
          lhs.signal.nextTime().handle(
            (_) -> this.trigger.trigger(Noise)
          );
        case [_,Waiting] : 
          this.status = Waiting;
          rhs.signal.nextTime().handle(
            (_) -> this.trigger.trigger(Noise)
          );
        default : 
      }
    }
  }
  override public function get_loaded(){
    return this.lhs.get_loaded() && this.rhs.get_loaded();
  }
}