package stx.async.test.type;

enum TaskResultType<T,E>{
  TaskPursue;
  TaskResult(t:T);
  TaskDefect(e:E);
  
  TaskLater(ft:Future<TaskResultType<T,E>>);
  TaskLogic(fn:Void->Bool,lhs:TaskResultType<T,E>,rhs:TaskResultType<T,E>);
}