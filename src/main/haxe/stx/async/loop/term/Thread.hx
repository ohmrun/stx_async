package stx.async.loop.term;

using stx.async.loop.term.Thread;

function log(wildcard:Wildcard){
  return stx.async.Log.log(__).tag(__.here().toPosition().identifier());
}
typedef ThreadMapDef = Array<Couple<String,stx.async.Thread>>;
abstract ThreadMap(ThreadMapDef) from ThreadMapDef to ThreadMapDef{
  static public var ZERO : ThreadMap = new ThreadMap();

  @:isVar static var instance(get,null) : ThreadMapDef;
  private static function get_instance():ThreadMapDef{
    return instance == null ? instance = [] : instance;
  }
  public function new(){
    this = instance;
  }
  public function get(thread:stx.async.Thread):String{
    return this.search(
      (tp) -> tp.snd() == thread
    ).map(
      (tp) -> tp.fst()
    ).def(
      () -> {
         var id = __.uuid("xxxxx");
         this.push(__.couple(id,thread));
         return id;
      }
    );
  }
}
class Thread extends LoopCls{
  var thread        : stx.async.Thread;
  var mutex         : Mutex;
  var ignitioned    : Bool;
  var was_suspended : Bool;

  public function new(){
    ////__.log().info('THREAD LOOP');
    this.thread         = null;
    this.ignitioned     = false;
    this.was_suspended  = false;
    this.mutex          = new Mutex();
    super();
  }
  override public function add(work:Work){
    //////__.log()('add work: $work from to ${__.option(Runtime.ZERO.current()).map( _ -> _.id)} to ${__.option(thread).map( _ -> _.id)}');
    super.add(work);
  }
  override public function reply(){
    //var thread_id = ThreadMap.ZERO.get(Runtime.unit().current());
    //var thread_id = ThreadMap.ZERO.get(thread);
    return super.reply();
  }
  function rec(){
    this.thread        = Runtime.ZERO.current();
    var loop          = thread.events;
    var event_handler = null;
        event_handler = loop.repeat(
          () -> {
            if(!reply()){
              loop.cancel(event_handler);
              exit();
            }
          }  
        ,0);
  }
  public function ignition(v:HookTag){
    if(!ignitioned){
      ignitioned = true;
      //////__.log().info('thread: ignition');
      Runtime.ZERO.createWithEventLoop(rec);
    }
  }
}