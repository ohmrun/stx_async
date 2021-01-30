package stx.async.goal.term;

class Seq extends Delegate{

  @:isVar var id(get,null):Int;
  public function get_id(){
    return this.id;
  }

  public function get_loaded(){
    return this.lhs.get_loaded() && this.rhs.get_loaded();
  }
  
  @:isVar public var status(get,set):GoalStatus;
  
  public function set_status(v){
    return this.status = v;
  }
  public function get_status(){
    return this.status;
  }
  

  var lhs : Goal;
  var rhs : Goal;
  var sel : Bool;

  public function new(lhs,rhs,pos){
    super(pos);
    this.id       = Counter.next();
    this.status   = Pending;
    this.lhs      = lhs;
    this.rhs      = rhs;
    this.sel      = false;
  }
  //defect.is_defined() && 
  public function pursue(){
    ////__.log()('pursue $this');
    __.log().debug('$sel ${get_loaded()} ${lhs.identifier().name} ${lhs.get_loaded()} ${rhs.identifier().name} ${rhs.get_loaded()}');
    if(!get_loaded()){
      switch(this.sel){
        case false : 
          __.log().debug('$lhs');
          switch(lhs.get_status()){
            case Problem :
            case Pending : 
              lhs.pursue();
              if(get_loaded()){
                set_status(Secured);
              }else if(lhs.get_loaded()){
                this.sel = true;
              }
            case Applied : sel = true;
            case Working : 
            case Waiting : 
              if(!this.lhs.get_loaded()){
                this.set_status(Waiting);
                this.lhs.signal.nextTime().handle(
                  (_) -> {
                    this.trigger.trigger(Noise);
                  }
                );
              }else{
                sel = true;
              }
            case Secured : 
              this.sel = true;
              pursue();
          }
        case true : 
          __.log().debug('rhs ${get_id()}:${rhs.get_status().toString()} $rhs');
          switch(rhs.get_status()){
            case Problem :
            case Pending : 
              rhs.pursue();
              //__.log().debug('rhs $rhs');
              if(rhs.get_status() == Secured){
                this.set_status(Secured);
              }
            case Applied :
              this.set_status(Secured);
            case Working : 
            case Waiting : 
              if(!this.rhs.get_loaded()){
                this.set_status(Waiting);
                this.rhs.signal.nextTime().handle(
                  (_) -> {
                    ////__.log().debug('$rhs arrived');
                    this.trigger.trigger(Noise);
                  }
                );
              }else{
                this.set_status(Secured);
              }
            case Secured :
              this.set_status(Secured);
          }
      } 
    }
  }
  public function escape(){
    this.lhs.escape();
    this.rhs.escape();
  }
  public function update(){
    this.lhs.update();
    this.rhs.update();
  }
  public function toString(){
    return 'goal.Seq[${get_id()} sel: $sel loaded:${get_loaded()}]($lhs $rhs)';
  }
} 