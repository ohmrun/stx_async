package stx.async.test.type;


class ChompyTask<T,E> extends stx.async.task.Direct<T,E>{
  var sequence : Array<TaskResultType<T,E>>;
  var index    : Int; 
  public function new(sequence:Array<TaskResultType<T,E>>){
    super();
    this.sequence = sequence;
    this.index    = 0;
  }
  override public function pursue(){
    handle(sequence[index++]);
  }
  private function handle(self:TaskResultType<T,E>){
    switch(self){
      case TaskPursue       : 
        ////__.log()('pursue');
      case TaskResult(t)    :
        ////__.log()('result: $t');
        this.result = t;
        this.status = Secured;
      case TaskDefect(e):
        ////__.log()('defect: $e');
        this.defect = [e];
        this.status = Problem;
      case TaskLater(ft) :
        ////__.log()('waiting');
        this.status = Waiting;
        ft.handle(
          (_) -> this.trigger.trigger(Noise)
        );
      case TaskLogic(fn,lhs,rhs) : 
        switch(fn()){
          case false : handle(lhs);
          case true  : handle(rhs);
        }
    }
  }
}