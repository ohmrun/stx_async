package stx.async.task.term;

class Par<T,Ti,E> extends TaskCls<Couple<T,Ti>,E>{
  var fst : TaskApi<T,E>;
  var snd : TaskApi<Ti,E>;

  public function new(fst:TaskApi<T,E>,snd:TaskApi<Ti,E>){
    super();
    this.fst = fst;
    this.snd = snd;
  }
  override public function pursue(){
    if(!defect.is_defined() && !loaded){
      this.fst.pursue();
      this.snd.pursue();
      switch([this.fst.status,this.snd.status]){
        case [Applied,Applied] : 
          this.status = Secured;
          this.result = __.couple(fst.result,snd.result);
          this.loaded = true;
        case [Problem,_] :
          this.defect = fst.defect;
          this.status = Problem;
        case [_,Problem] :  
          this.defect = snd.defect;
          this.status = Problem;
        case [Secured,Secured] : 
          this.loaded = true;
          this.status = Secured;
          this.result = __.couple(fst.result,snd.result);
        case [Waiting,Waiting] : 
          this.status = Waiting;
          this.init_signal();
          __.assert().exists(fst.signal);
          __.assert().exists(snd.signal);

          fst.signal.nextTime().merge(
            snd.signal.nextTime(),
            (_,_) -> Noise
          ).handle(
            (_) -> this.trigger.trigger(Noise)
          );
        case [Waiting,_] : 
          this.status = Waiting;
          this.init_signal();
          __.assert().exists(fst.signal);
          fst.signal.nextTime().handle(
            (_) -> this.trigger.trigger(Noise)
          );
        case [_,Waiting] : 
          this.status = Waiting;
          this.init_signal();
          __.assert().exists(snd.signal);
          snd.signal.nextTime().handle(
            (_) -> this.trigger.trigger(Noise)
          );
        default : 
      }
    }
  }
}