package stx.async.tick;

abstract class Abs implements Api extends stx.async.transmit.Abs{
  abstract public function pursue():Void;
  abstract public function escape():Void;
  abstract public function update():Void;
}