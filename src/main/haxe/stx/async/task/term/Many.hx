package stx.async.task.term;

class Many<T,E> extends Direct<Array<T>,E>{
  var tasks   : Array<Task<T,E>>;
  var results : Array<T>;
  var cursor  : Int;

  public function new(tasks,?pos:Pos){
    super(pos);
    this.tasks  = tasks;
    this.cursor = 0;
  }
  @:isVar public var loaded(get,null):Bool;

  override public function get_loaded():Bool{
    return this.loaded;
  }
  override public function pursue(){
    if(!get_loaded()){
      if(cursor == tasks.length && get_status() != Problem){
        this.loaded = true;
        set_status(Secured);
      }else{
        var task = tasks[cursor];
        switch(task.get_status()){
          case Problem : set_status(Problem);
          case Pending : task.pursue();
          case Applied : 
            task.pursue();
            switch(task.get_status()){
              case Problem : 
                set_status(Problem);
              case Secured : 
                cursor++;
              default : 
                //TODO who bears responsibility for cleanup here?
            }
          case Working : 
            set_status(Working);
          case Waiting : 
            set_status(Waiting);
            task.signal.nextTime().handle(
              _ -> this.trigger.trigger(Noise)
            );
          case Secured : 
            cursor = cursor + 1;
        }
      }
    }
  }
  override public function escape(){
    for(task in tasks){
      task.escape();
    }
  }
  override public function update(){
    for(task in tasks){
      task.update();
    }
  }
  override public function get_defect(){
    return __.option(tasks[cursor]).map( _ -> _.get_defect()).def(Defect.unit);
  }
  override public function get_result(){
    return this.tasks.map_filter(
      (task) -> __.option(task.get_result())
    );
  }
  override public function toString(){
    var n = __.definition(this).identifier().name;
    var xs = this.tasks.map(
      t -> {
        var n   = __.definition(t).identifier().name;
        var id  = t.get_id();
        var s   = t.get_status();
        return '$n:$id($s)';
      }
    ).join(",");
    return  '$n[$xs]';
  }
}