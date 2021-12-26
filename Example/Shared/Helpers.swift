// for some reason ReferenceWritableKeyPath is not converible to function via type-inference in pullback
func get<Object: AnyObject, Value>(
  _ keyPath: ReferenceWritableKeyPath<Object, Value>
) -> (Object) -> Value {
  return { $0[keyPath: keyPath] }
}
