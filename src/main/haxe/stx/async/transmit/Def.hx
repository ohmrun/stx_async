package stx.async.transmit;


typedef Def = stx.async.declared.Def & {
  @:isVar public var signal(get,null):Signal<Noise>;
  public function get_signal():Signal<Noise>;
}