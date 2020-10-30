package stx.async;

@:forward abstract Defect<E>(Array<E>) from Array<E> to Array<E>{
  @:noUsing static public function unit<E>():Defect<E>{
    return [];
  }
  @:to public inline function toErr():Err<E>{
    return Err.grow(this);
  }
  public function elide():Defect<Dynamic>{
    return this;
  }
}