package stx.async;

import stx.async.work.term.*;

typedef WorkApi = Task<Any,Any>;

@:using(stx.async.Work.WorkLift)
@:forward abstract Work(WorkApi) from WorkApi to WorkApi{
  @:noUsing static public function lift(self:WorkApi):Work{
    return new Work(self);
  }
  @:from @:noUsing static public function fromFutureWork(ft:Future<Work>):Work{
    return Task.Later(ft);
  }
  @:from static public function fromFunXX(fn:Void->Void):Work{
    return lift(new stx.async.work.term.Block(fn));
  }
  public function new(self) this = self;
 
  public function submit(?loop:Loop){
    __.log().debug('submit: $loop');
    __.option(loop).defv(Loop.ZERO).add(this);
  }
  public function crunch(?loop){
    loop          = __.option(loop).defv(Loop.ZERO);
    var self      = this;
    var cont      = true;
    var suspended = false;
    var backoff   = 0.2;

    while(true == cont){
      __.log().debug('crunch: suspended? $suspended');
      if(!suspended){
        self.pursue();
        if(self.loaded){
          cont = false;
        }else{
          switch(self.status){
            case Waiting : 
              suspended = true;
              self.signal.nextTime().handle(
                _ -> {
                  backoff   = 1.22;
                  suspended = false;
                }
              );
            case Problem :
              loop.crack(self.defect);
            case Pending | Working : 
            case Secured | Applied : cont = false;
          }
        }
      }else{
        #if sys
          Sys.sleep(backoff);
          backoff = backoff * 1.22;
        #end
      }
    }
  }
}
class WorkLift{
  static public function seq(self:Work,that:Work):Work{
    return Task.Seq(
      self,
      that
    );
  }
  static public function par(self:Work,that:Work):Work{
    return Task.Par(
      self,
      that
    );
  }
}