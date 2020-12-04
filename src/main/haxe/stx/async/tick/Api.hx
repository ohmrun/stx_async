package stx.async.tick;

interface Api extends stx.async.transmit.Api{
  /**
    Continue Process
  **/
  public function pursue():Void;
  /**
    Exit Process
  **/
  public function escape():Void;
  /**
    Housekeeping.
  **/
  public function update():Void;
}