using stx.Async;
using stx.Log;

class Main {
	static function main() {
		init_log_facade();
		//stx.async.Test.main();
		var test = new stx.async.Test.SubmitTest();
				test.test_loop(null);
	}
	static function init_log_facade(){
		var f = stx.log.Facade.unit();
				f.includes.push("stx.async");
	}
}
