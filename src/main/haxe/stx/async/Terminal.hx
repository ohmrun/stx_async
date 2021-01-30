package stx.async;

import stx.async.terminal.*;

using stx.async.Terminal;

function log(wildcard:Wildcard){
  return stx.async.Log.log(__).tag(__.here().lift().identifier());
}
@:forward abstract Terminal<R,E>(Api<R,E>) from Api<R,E> to Api<R,E>{
  //static private var ZERO = new Terminal();
  static public inline function lift<R,E>(self:Api<R,E>,?pos:Pos):Terminal<R,E>{
    return new Terminal(self,pos);
  }
  public inline function new(?self:Terminal<R,E>,?pos:Pos){
    this = __.option(self).def(() -> @:privateAccess new Cls(pos));
  }
  static public function identifier(){
    return __.here().lift().identifier();
  }
  static public function Logging<R,E>(terminal:Terminal<R,E>):Terminal<R,E>{
    return new stx.async.terminal.term.Logging(terminal);
  }
}