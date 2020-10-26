package stx.async;

/**
  Too early to use `stx.Log` in the bootstrap as it uses `tink.Signal.defer() -> Timer.delay() -> Thread.current()`
**/
class Hook{
  @:isVar private static var initialized(get,set) : Bool;
  static private function get_initialized(){
    return initialized == null ? initialized = false : initialized;
  }
  static private function set_initialized(b:Bool):Bool{
    return initialized = b;
  }
  @:isVar static private var loops(get,null) : Array<Loop>;
  static private function get_loops(){
    return loops == null ? loops = [] : loops;
  }
  static public function notify(loop:Loop){
    loops.push(loop);
    initialize();
  }
  static private inline function initialize(){
    //trace('initialize');
    //__.log().info('initialize');
    if(initialized == false){
      initialized = true;
      initializing();
    }
  }
  // #if sys
  // @:nb("26/10/2020","Event loop is not available, so this way")
  // static private inline function initializing(){
  //   //trace('initializing');
  //   initializer(()->{});
  // }
  // #else
  @:doc("In event targets, let the main() function finish before kicking off processing")
  static private inline function initializing(){
    //trace('initializing');
    #if sys
      //@:privateAccess sys.thread.Thread.initEventLoop();
    #end
    var event : MainEvent = null;
        var get_event = () -> event.stop();
        event = MainLoop.add(initializer.bind(get_event));
  }
  //#end

  @:access(stx) static private inline function initializer(canceller:Void->Void){
    //trace('initializer');
    //__.log().info('initializer');
    for(loop in loops){
      loop.ignition(new HookTag());
    }
    canceller();
  }
}
@:allow(stx.async.Hook) abstract HookTag(Noise){
  private function new(){
    this = Noise;
  }
}