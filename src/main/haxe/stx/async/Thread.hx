package stx.async;


/**
  06/10/2020: Compiler giving errors regarding sys.thread.Thread when I tried to initialize Map, so.
**/
import sys.thread.EventLoop;

typedef ThreadDef = {
    public var events(get,never):EventLoop;
    public function get_events():EventLoop;

    public function sendMessage(msg:Dynamic):Void;

    public var runtime(get,null):Runtime;

    public var delegate(default,null) : StdThread;

    public var id(get,never)          : String;
    public function get_id():String;
} 
interface ThreadApi{
  public var events(get,never):EventLoop;
  public function get_events():EventLoop;

  public function sendMessage(msg:Dynamic):Void;
  public var delegate(default,null) : StdThread;

  public var id(get,never)          : String;
  public function get_id():String;
}
class ThreadCls implements ThreadApi{
  public var delegate(default,null) : StdThread;

  public function new(delegate){
    this.delegate = delegate;
  }
  public var events(get,never):EventLoop;
  public inline function get_events():EventLoop{
    return this.delegate.events;
  }
  public inline function sendMessage(msg:Dynamic):Void{
    this.delegate.sendMessage(msg);
  }
  public var id(get,never)          : String;
  public inline function get_id():String{
    return ThreadMap.ZERO.get(this);
  }
}
@:forward(events,sendMessage,id) abstract Thread(ThreadApi) from ThreadApi to ThreadApi{
  static inline public function make(job:Void->Void):Thread{
    return new ThreadCls(StdThread.create(job));
  }
  static inline public function lift(self:StdThread):Thread{
    __.assert().exists(self);
    return new ThreadCls(self);
  }
  @:op(A == B)
  public function equals(that:Thread){
    return this == null || that == null ? false : this.delegate == @:privateAccess that.prj().delegate;
  }
  private inline function prj():ThreadApi{
    return this;
  }
}