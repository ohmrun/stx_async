package stx.async;

using stx.async.Loop;

function log(wildcard:Wildcard):stx.Log{
  return stx.async.Log.log(__).tag('stx.async.Loop');
}
interface LoopApi{
  private var suspended:Array<Work>;
  private var threads:List<Work>;

  public function add(work:Work):Void;

  public dynamic function fail(error:Dynamic):Void;
  public dynamic function exit():Void;

  public function initialize():Void;

  private function ignition(v:HookTag):Void;
}

abstract class LoopCls implements LoopApi{

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
    //__.log().debug('add: $work');
    initialize();
    threads.add(work);
  }
  public dynamic function fail(error:Dynamic){
    throw error;
  }
  public dynamic function exit(){
    
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
          fail(e);
          break;
        }
        
        var ready     = work.get_loaded();
        //__.log()('$work');
        if(!ready){
          switch(work.get_status()){
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
              throw work.get_defect();
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
  abstract function ignition(v:HookTag):Void;

  public function toString(){
    var name = __.definition(this).identifier().name;
    return '$name(initialized:$initialized,suspended:$suspended,threads:$threads)';
  }
}

@:forward abstract Loop(LoopApi) from LoopApi to LoopApi{

  static public var ZERO(default,null):Loop = #if sys Loop.Thread() #else Loop.Event() #end;
  #if target.threaded
  static public function Thread(){
    return new stx.async.loop.term.Thread();
  }
  #end
  #if (sys || hxnodejs)
  static public function Step(){
    return new stx.async.loop.term.Step();
  }
  #end
  static public function Event(){
    return new stx.async.loop.term.Event();
  }
}
