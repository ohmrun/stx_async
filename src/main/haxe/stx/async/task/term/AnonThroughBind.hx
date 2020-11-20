package stx.async.task.term;

class AnonThroughBind<T,Ti,E> extends ThroughBind<T,Ti,E>{
  public function new(delegate,__through_bind){
    super(delegate);
    this.__through_bind = __through_bind;
  }
  dynamic function __through_bind(outcome:Outcome<T,Defect<E>>):TaskApi<Ti,E>{
    return new Fail([]);
  }

  override inline function through_bind(outcome:Outcome<T,Defect<E>>):TaskApi<Ti,E>{
    return __through_bind(outcome);
  }
}