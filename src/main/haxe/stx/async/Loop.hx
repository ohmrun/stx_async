package stx.async;

using stx.async.Loop;

function log(wildcard:Wildcard):stx.Log{
  return new stx.Log().tag('stx.async.Loop');
}
interface LoopApi{
  private var suspended:Int;
  private var threads:Array<Work>;

  public function add(work:Work):Void;
  public function crack(error:Dynamic):Void;

  public function initialize():Void;

  private function ignition(v:HookTag):Void;
}

class LoopCls implements LoopApi{

  var initialized : Bool;

  /**
    If I use a static var for the ZERO Loop, the event loop is not initialized.
    If I don't, I can't be sure it's on the main thread.
    Not sure about initializing the event loop.
  **/
  public function initialize(){
    if(!initialized){
      initialized = true;
      stx.async.Hook.notify(this);
    }
  }
  public function new(){
    this.suspended    = 0;
    this.threads      = [];
    this.initialized  = false;
    //initialize();// nb this is too early
  }
  var suspended : Int;
  var threads   : Array<Work>;

  public function add(work:Work){
    __.log()('add: $work');
    initialize();
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
  static public function Thread(){
    return new stx.async.loop.term.Thread();
  }
  static public function Event(){
    return new stx.async.loop.term.Event();
  }
  private function ignition(v:HookTag):Void{
    __.crack(__.fault().err(FailCode.E_AbstractMethod));
  }
}

@:forward abstract Loop(LoopApi) from LoopApi to LoopApi{

  @:nb("Too early to use `stx.Log` inside here as it uses `tink.Signal.defer() -> Timer.delay() -> Thread.current()`.")
  static public var ZERO(default,null):Loop = #if sys Loop.Thread() #else Loop.Event() #end;
  #if sys
  static public function Thread(){
    return new stx.async.loop.term.Thread();
  }
  #end
  static public function Event(){
    return new stx.async.loop.term.Event();
  }
}
