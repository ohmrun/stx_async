package stx.async.goal.term;

class Par extends Direct{
  var array   : Array<Goal>;

  public function new(array,?pos:Pos){
    super(pos);
    this.array = array;
  }
  private function get_sub_status():GoalStatus{
    return array.map(
      task -> task.get_status()
    ).lfold1(
      (next,memo) -> switch([memo,next]){
        case [Problem,_]          : Problem;
        case [_,Problem]          : Problem;
        case [Applied,Applied]    : Applied;        
        case [_,Applied]          : Pending;
        case [Applied,_]          : Pending;

        case [_,Pending]          : Pending;
        case [Waiting,Working]    : Waiting;

        case [x,Working]          : x;
        case [Working,x]          : x;


        case [Waiting,x]          : x;
        case [x,Waiting]          : x;

        case [Secured,Secured]    : Secured;
        case [Secured,x]          : x;
        case [x,Secured]          : x;
      }
    ).defv(Problem);
  }
  override public function get_loaded(){
    return array.map(
      task -> task.get_loaded()
    ).lfold1(
      (n,m) -> n && m
    ).defv(false);
  }
  public function pursue(){
    if(!get_loaded()){
      switch(get_sub_status()){
        case Problem : 
        case Applied : 
          for(goal in array){
            goal.pursue();
          }
          this.set_status(Secured);
        case Pending : 
          for(goal in array){
            goal.pursue();
          }
        case Working :
        case Waiting : 
          var waits = [];
          for(goal in array){
            if(goal.get_status() == Waiting){
              waits.push(goal);
            }
          }
          waits.lfold(
            (next:Goal,memo:Future<Noise>) -> memo.merge(next.signal.nextTime(),(_,_) -> Noise),
            Future.sync(Noise)
          ).handle(
            (_) -> this.trigger.trigger(Noise)
          );
        case Secured :
          this.set_status(Secured);
      }
    } 
  }
  public function escape(){
    for(goal in array){
      goal.escape();
    }
  }
  public function update(){
    for(goal in array){
      goal.update();
    }
  }
  public function toString(){
    var contents =  this.array.map(
      (goal) -> goal.toString()
    ).join(",");

    return 'Par($contents)';
  }
}