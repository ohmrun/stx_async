package stx.async.task;

class Util{
  static public function toString<R,E>(self:TaskApi<R,E>){
    var name = __.definition(self).identifier().name;
    return '$name:${self.get_id()}[${self.get_status()}]@(${self.pos.lift().toString_name_method_line()})';
  }
  // static public function toStringDelegate<R,Rii,E,Eii>(self:TaskApi<R,E>,delegate:TaskApi<R,E>):String{
  //   return '$name:${self.id}(${self.get_status().toString()}@${self.pos.lift().toString_name_method_line()}';
  //   return 
  // }
}