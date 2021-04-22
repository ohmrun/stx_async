package stx.async.transmit;

import tink.core.Signal;

abstract class Abs extends stx.async.declared.Abs{
  public function new(?pos:Pos){
    super(pos);
    this.transmission_enabled = false;
  }
  private var transmission_enabled : Bool;

  @:isVar public var signal(get,null):Signal<Noise>;
  public function get_signal():Signal<Noise>{
    return transmission_enabled ? this.signal : {
      this.transmission_enabled = true;
      this.trigger = Signal.trigger();
      this.signal  = trigger.asSignal();
      this.signal;
    }
  }
  @:isVar private var trigger(get,null):SignalTrigger<Noise>;
  private function get_trigger():SignalTrigger<Noise>{
    return transmission_enabled ? this.trigger : {
      this.transmission_enabled = true;
      this.trigger = Signal.trigger();
      this.signal  = trigger.asSignal();
      this.trigger;
    }
  }
}