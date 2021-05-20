/// Use this property wrapper to declare depencies in a ComposableEnvironment subclass.
@propertyWrapper
public struct Dependency<Value> {
  @inlinable
  public static subscript<EnclosingSelf: ComposableEnvironment>(
    _enclosingInstance instance: EnclosingSelf,
    wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>,
    storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Self>
  ) -> Value {
    get {
      let wrapper = instance[keyPath: storageKeyPath]
      let keyPath = wrapper.keyPath
      let value = instance.dependencies[keyPath: keyPath]
      return value
    }
    set {
      fatalError("@Dependency are read-only in their ComposableEnvironment")
    }
  }

  @usableFromInline
  var keyPath: KeyPath<ComposableDependencies, Value>

  public init(_ keyPath: KeyPath<ComposableDependencies, Value>) {
    self.keyPath = keyPath
  }

  public var wrappedValue: Value {
    get { fatalError("@Dependency should be used in a ComposableEnvironment class.") }
    set { fatalError("@Dependency should be used in a ComposableEnvironment class.") }
  }
}
