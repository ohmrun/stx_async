package stx.async.loop.term;

class Step extends Event{
  override function rec(){
    var char = Sys.getChar(true);
    if(char == 3){
      Sys.exit(0);
    }else if(char == 13){
      Sys.print('\n');
      super.rec();
    }else{
      rec();
    }
  }
}