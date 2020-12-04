package stx.async.transmit;

interface Api extends stx.async.declared.Api{
  private var transmission_enabled : Bool;

  @:isVar public var signal(get,null):Signal<Noise>;
  public function get_signal():Signal<Noise>;

  @:isVar private var trigger(get,null):SignalTrigger<Noise>;
  private function get_trigger():SignalTrigger<Noise>;
}