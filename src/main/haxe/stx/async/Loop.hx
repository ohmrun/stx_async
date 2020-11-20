package stx.async;

using stx.async.Loop;

function log(wildcard:Wildcard):stx.Log{
  return new stx.Log().tag('stx.async.Loop');
}
interface LoopApi{
  private var suspended:Array<Work>;
  private var threads:List<Work>;

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
    this.suspended    = [];
    this.threads      = new List();
    this.initialized  = false;
    //initialize();// nb this is too early
  }
  var suspended : Array<Work>;
  var threads   : List<Work>;

  public function add(work:Work){
    ////__.log().debug('add: $work');
    initialize();
    threads.add(work);
  }
  public function crack(error:Dynamic){
    throw error;
  }
  public function reply(){
    //__.log()('$this');
    var next : Option<Work> = __.option(threads.pop());
    //__.log()('has next? ${next.is_defined()}');
      return if(next.is_defined()){
      for(work in next){
        //__.log()('work on: $work of ${threads.length}');
        try{
          work.pursue();
        }catch(e:Dynamic){
          on_error(e);
          break;
        }
        //__.log()('$work');
        var ready     = work.loaded;
        if(!ready){
          switch(work.status){
            case Waiting : 
              //__.log().debug('suspend: $work');
              suspended.push(work);
              work.signal.nextTime().handle(
                (_) -> {
                  suspended.remove(work);
                  threads.push(work);
                }
              );
            case Applied : 
              throw "`Applied` tasks should always only take one `pursue` call to resolve";
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
    }else if(suspended.length > 0){
      //__.log().debug(suspended.map(_ -> _.toString()));
      true;
    }else{
      false;
    }
  }
  dynamic function on_error(e:Noise):Void{
    //__.log().fatal(e);
    __.crack(e);
  }
  #if target.threaded
  static public function Thread(){
    return new stx.async.loop.term.Thread();
  }
  #else
  
  #end
  static public function Event(){
    return new stx.async.loop.term.Event();
  }
  private function ignition(v:HookTag):Void{
    __.crack(__.fault().err(FailCode.E_AbstractMethod));
  }
  public function toString(){
    var name = __.definition(this).identifier().name();
    return '$name(initialized:$initialized,suspended:$suspended,threads:$threads)';
  }
}

@:forward abstract Loop(LoopApi) from LoopApi to LoopApi{

  @:nb("Too early to use `stx.Log` inside here as it uses `tink.Signal.defer() -> Timer.delay() -> Thread.current()`.")
  static public var ZERO(default,null):Loop = #if sys Loop.Thread() #else Loop.Event() #end;
  #if target.threaded
  static public function Thread(){
    return new stx.async.loop.term.Thread();
  }
  #end
  static public function Event(){
    return new stx.async.loop.term.Event();
  }
}
