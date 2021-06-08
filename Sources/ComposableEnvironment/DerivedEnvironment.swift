@propertyWrapper
public final class DerivedEnvironment<Value> where Value: ComposableEnvironment {
  public static subscript<EnclosingSelf: ComposableEnvironment>(
    _enclosingInstance instance: EnclosingSelf,
    wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>,
    storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, DerivedEnvironment>
  ) -> Value {
    get {
      let environment = instance[keyPath: storageKeyPath].environment
      instance.knownChildren.insert(storageKeyPath)
      if environment.hasReceivedDependenciesFromParent {
        return environment
      }
      environment.dependencies.mergeFromUpstream(instance.dependencies)
      environment.hasReceivedDependenciesFromParent = true
      return environment
    }
    set {
      fatalError("@DerivedEnvironments are read-only in their parent")
    }
  }

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
