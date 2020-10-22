package stx;


class Async{
  static public function timer(wildcard:Wildcard){
    return new Timer();
  }
}
@:using(stx.Async.TaskControlLift)
enum TaskControl{
  Pursue;
  Escape;
}
class TaskControlLift{
  static public function fold<Z>(self:TaskControl,pursue:Void->Z,escape:Void->Z):Z{
    return switch(self){
      case Pursue: pursue();
      case Escape: escape();
    }
  }
}

typedef TaskApi<R,E>  = stx.async.Task.TaskApi<R,E>;
typedef TaskCls<R,E>  = stx.async.Task.TaskCls<R,E>;
typedef Task<R,E>     = stx.async.Task<R,E>;
typedef Work          = stx.async.Work;
typedef Terminal<R,E> = stx.async.Terminal<R,E>;
typedef TimerDef      = stx.async.Timer.TimerDef;
typedef Timer         = stx.async.Timer;

typedef TickDef = {
  public function delay(float:Null<Float>):Void;
  public function stop():Void;
}
interface LoopApi{
  private var suspended:Int;
  private var threads:Array<Work>;

  public function add(work:Work):Void;
  public function crack(error:Dynamic):Void;

  public function ignition():Void;
}
class LoopCls implements LoopApi{

  public function new(){
    this.suspended  = 0;
    this.threads    = [];
  }
  var suspended : Int;
  var threads   : Array<Work>;

  public function add(work:Work){
    __.log()('add: $work');
    threads.push(work);
  }
  public function crack(error:Dynamic){
    throw error;
  }
  public function reply(){
    __.log()("Loop.rec");
    var next : Option<Work> = __.option(threads.shift());
    __.log()('has next? ${next.is_defined()}');
      return if(next.is_defined()){
      for(work in next){
        __.log()('work on: $work');
        try{
          work.pursue();
        }catch(e:Dynamic){
          on_error(e);
          break;
        }
        __.log()('$work');
        var ready     = work.loaded;
        if(!ready){
          switch(work.status){
            case Waiting : 
              suspended = suspended + 1;
              work.signal.nextTime().handle(
                (_) -> {
                  suspended = suspended - 1;
                  threads.push(work);
                }
              );
            case Applied : 
              throw "applied should always only take one `pursue` call to resolve";
            case Problem : 
              throw work.defect;
            case Secured : 
            case Pending : 
              threads.push(work);
            case Working : 
              threads.push(work);
          }
        }
      }
      true;
    }else if(suspended > 0){
      true;
    }else{
      false;
    }
  }
  dynamic function on_error(e:Noise):Void{
    __.log().fatal(e);
    __.crack(e);
  }
  public function ignition():Void{
    __.crack(__.fault().err(FailCode.E_AbstractMethod));
  }
}
class EventLoopCls extends LoopCls{
  var tick : TickDef;
  override public function add(work:Work){
    super.add(work);
    ignition();
  }
  function rec(){
    if(!reply()){
      tick.stop();
    }
  }
  override public function ignition(){
    if(tick == null){
      tick = MainLoop.add(rec);
    }
  }
}
#if sys
class ThreadLoopCls extends LoopCls{
  var initialized : Bool;
  public function new(){
    this.initialized = false;
    super();
  }
  override public function add(work:Work){
    __.log()('add work: $work');
    super.add(work);
  }
  function rec(){
    while(true){
      var output = reply();
      __.log()('continue? $output');
      if(!output){
        break;
      }
    }
  }
  override public function ignition(){
    if(!initialized){
      this.initialized = true;
      MainLoop.addThread(rec);
    }
  }
}
#end
@:forward abstract Loop(LoopApi) from LoopApi to LoopApi{
  static public var ZERO(default,null):Loop = new LoopCls();
  #if sys
  static public function Thread(){
    return new ThreadLoopCls();
  }
  #end
}
class Stat{
  public var last(default,null):Float;
  public var duration(default,null):Float;
  public function new(){}
}