package stx.async;

class Hook{
  @:isVar private static var initialized(get,set) : Bool;
  static private function get_initialized(){
    return __.option(initialized).is_defined() ? initialized : initialized = false;
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
    initialize();//TODO fix this.
  }
  static private inline function initialize(){
    #if target.threaded
      ////__.log().debug('initialize: ${__.option(Runtime.ZERO.main()).map( _ -> _.id)}');
    #else
      ////__.log().debug('initialize');
    #end
    ////__.log().info('initialize');
    if(initialized == false){
      initialized = true;
      initializing();
    }else{
      initializer(()->{});
    }
  }
  // #if sys
  // @:nb("26/10/2020","Event loop is not available, so this way")
  // static private inline function initializing(){
  //   ////__.log().debug('initializing');
  //   initializer(()->{});
  // }
  // #else
  @:doc("In event targets, let the main() function finish before kicking off processing")
  static private function initializing(){
    //__.log().debug('initializing');
    #if sys
      trace(@:privateAccess sys.thread.Thread.current().events);
    #end
    var event : MainEvent = null;
        var get_event = () -> event.stop();
        event = MainLoop.add(initializer.bind(get_event));
  }
  //#end

  @:access(stx) static private inline function initializer(canceller:Void->Void){
    //__.log().debug('initializer');
    ////__.log().info('initializer');
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