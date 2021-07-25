@_exported import ComposableEnvironment

@dynamicMemberLookup
open class AutoComposableEnvironment: ComposableEnvironment {
  /// Direct access to a dependency using its defining accessor in ``ComposableDependencies`` at call site.
  public subscript<Value>(dynamicMember keyPath: WritableKeyPath<ComposableDependencies, Value>) -> Value {
    get { self[keyPath] }
    set { self[keyPath] = newValue }
  }
}
