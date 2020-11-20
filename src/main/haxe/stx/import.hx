import haxe.Timer;
import haxe.MainLoop;

import tink.CoreApi;

#if target.threaded
import stx.alias.StdThread;
import sys.thread.Mutex;
#end
using stx.Fn;
using stx.Nano;
using stx.Pico;
using stx.Log;
using stx.Assert;
using stx.Async;
using stx.async.Log;

