package stx.async.work;

using stx.async.work.Crunch;

function log(wildcard:Wildcard){
  return stx.Log.unit().tag(Crunch.identifier());
}
class Crunch{
  static public inline function apply(self:Work,loop:Loop):Void{
    loop          = __.option(loop).defv(Loop.ZERO);
    var cont      = true;
    var suspended = false;
    var backoff   = 0.2;
    //__.log().debug('$self');
    while(true == cont){
      //__.log().debug('crunch: suspended? $suspended');
      if(self.defect.is_defined()){
        loop.crack(self.defect);
        cont = false;
      }
      if(!suspended){
        self.pursue();
        if(self.loaded){
          //__.log().debug("done");
          cont = false;
        }else{
          //__.log().debug('${self}');
          //__.log().debug('status: ${self.status.toString()}');
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