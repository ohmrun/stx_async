package stx.async;

@:using(stx.async.Job.JobLift)
abstract Job(Work){
  public function new(self) this = self;
  static public function lift(self:Work):Job return new Job(self);
  

  

  public function prj():Work return this;
  private var self(get,never):Job;
  private function get_self():Job return lift(this);
}
class JobLift{
  
}