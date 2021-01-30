package stx.async.task.term;

class AnonFlatMap<T,Ti,E> extends FlatMap<T,Ti,E>{
  public function new(deferred:TaskApi<T,E>,__flat_map,?pos:Pos){
    super(deferred,pos);
    this.__flat_map = __flat_map;
  }
  public dynamic function __flat_map(t:T):TaskApi<Ti,E>{
    return throw 'Constructor not called';
  }
  public inline function flat_map(t:T):TaskApi<Ti,E>{
    return __flat_map(t);
  }
}