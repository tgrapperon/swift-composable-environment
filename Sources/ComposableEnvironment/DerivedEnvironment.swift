@propertyWrapper
public final class DerivedEnvironment<Value> where Value: ComposableEnvironment {
  @inlinable
  public static subscript<EnclosingSelf: ComposableEnvironment>(
    _enclosingInstance instance: EnclosingSelf,
    wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>,
    storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, DerivedEnvironment>
  ) -> Value {
    get {
      let environment = instance[keyPath: storageKeyPath].environment
      environment.dependencies.mergeFromUpstream(instance.dependencies)
      return environment
    }
    set {
      fatalError("@DerivedEnvironments are read-only in their parent")
    }
  }

  @usableFromInline
  var environment: Value

  public init(wrappedValue: Value) {
    self.environment = wrappedValue
  }

  public init() {
    self.environment = Value()
  }

  public var wrappedValue: Value {
    get { fatalError("@DerivedEnvironment should be used in a ComposableEnvironment class.") }
    set { fatalError("@DerivedEnvironment should be used in a ComposableEnvironment class.") }
  }
}
