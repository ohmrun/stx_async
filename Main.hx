using stx.Async;
using stx.Nano;
using stx.Log;

class Main {
	static function main() {
		//__.log()("main");
		init_log_facade();
		stx.async.Test.main();
		//var test = new stx.async.Test.SubmitTest();
			//test.test_loop(null);
	}
	static function init_log_facade(){
		var f = stx.log.Facade.unit();
				f.includes.push("stx.async");
				//f.includes.push("stx.async.work.Crunch");
				f.includes.push(Terminal.identifier());
				f.level = DEBUG;
	}
}
