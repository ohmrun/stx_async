# stx_async

## TaskApi
```haxe
function apply(control:TaskControl):Slot<Either<Task<T,E>,Outcome<T,E>>>
```
Either the `Task` returns another Task to be run, or an `Outcome`, 
the use of `Slot` provides a fast path where data is already available. Task is a monad.

`Work` is a `Task` which produces no value, but is composable either sequentialy `work.seq` or in parallel `work.par`

`Terminal` is an organising class that manages the use of the values generated by `Tasks`, their reification into `Work`, the ordering of the work and the running of the completed algorithm.


`submit` sends the work to scheduler in an asynchronous way, any values produced by any `Task`s are not available in the calling context.

`crunch` attempts to finish the work in the current calling context.

`Work` must be forwarded manually in order to be used. The abstraction which allows this organisation to be automated under the hood is found in `stx_arrowlets` which uses the `Terminal` to construct combinators.