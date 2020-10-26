package stx.async.pack;

class GlobalLock{
  static var initialised                    : Bool = false;

  static public var instance(default,null)  : GlobalLock = new GlobalLock();

  public var spare(default,null)            : Int;
  private var event(default,null)           : MainEvent;
  private var running(default,null)         : Bool;

  public function new(){
    this.spare    = 0;
    this.running  = false;

    if(!initialised){
      initialised = true;
      start();
    }
  }
  private function start(){
    this.running = true;
    this.event   = MainLoop.add(run);
  }
  private function stop(){
    this.running = false;
    this.event.stop();
  }
  private function run(){
    if(spare <= 0){
      stop();
    }
  }
  public function inc(){
    this.spare = this.spare + 1;
    if(!running){
      start();
    }
  }
  public function dec(){
    this.spare = this.spare - 1;
    // if(spare<=0){
    //   stop();
    // }
  }
}