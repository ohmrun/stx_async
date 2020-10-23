package stx.async.task.term;

class Seq<T,Ti,E> extends TaskCls<Couple<T,Ti>,E>{
  var fst : TaskApi<T,E>;
  var snd : TaskApi<Ti,E>;

  var sel : Bool;

  public function new(fst:TaskApi<T,E>,snd:TaskApi<Ti,E>){
    super();
    this.fst = fst;
    this.snd = snd;
    this.sel = false;
  }
  override public function pursue(){
    if(defect==null && !loaded){
      switch(this.sel){
        case false : 
          fst.pursue();
          switch(fst.status){
            case Pending :
            case Secured : 
              sel = true;
            case Problem : 
              this.defect = fst.defect;
            case Waiting : 
              if(!this.fst.loaded){
                init_signal();
                __.assert().exists(this.fst.signal);
                this.status = Waiting;
                this.fst.signal.nextTime().handle(
                  (_) -> this.trigger.trigger(Noise)
                );
              }else{
                sel = true;
              }
            case Working : 
            case Applied : 
              sel = true;
          }
        case true : 
          snd.pursue();
          __.log().debug('seq snd $snd ${snd.status}');
          switch(snd.status){
            case Pending : 
            case Secured :
              loaded = true;
              this.status = Secured;
              this.result = __.couple(this.fst.result,this.snd.result);
            case Waiting : 
              if(!this.snd.loaded){
                init_signal();
                __.assert().exists(this.snd.signal);
                this.status = Waiting;
                this.snd.signal.nextTime().handle(
                  (_) -> {
                    __.log().debug('$snd arrived');
                    this.trigger.trigger(Noise);
                  }
                );
              }else{
                __.assert().exists(this.fst.result);
                __.assert().exists(this.snd.result);
                this.status = Secured;
                this.result = __.couple(this.fst.result,this.snd.result);
              }
            case Problem :
              this.defect = snd.defect;
            case Applied :
              this.loaded = true;
              this.result = __.couple(this.fst.result,this.snd.result);
              this.status = Secured;
            case Working : 
          }
      } 
    }
  }
  public function toString(){
    return '$sel of $fst -> $snd';
  }
}