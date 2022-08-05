import ComposableDependencies

/// Use this property wrapper to declare depencies in a ``ComposableEnvironment`` subclass.
///
/// You reference the dependency by its `KeyPath` originating from  `Dependencies`, and
/// you declare its name in the local environment. The dependency should not be instantiated, as it
/// is either inherited from a ``ComposableEnvironment`` parent, or installed with
/// ``ComposableEnvironment/with(_:_:)``.
///
/// For example, if the dependency is declared as:
/// ```swift
/// extension Dependencies {
///   var uuidGenerator: () -> UUID {
///     get { self[UUIDGeneratorKey.self] }
///     set { self[UUIDGeneratorKey.self] = newValue }
///   }
/// },
/// ```
/// you can install it in `LocalEnvironment` like:
/// ```swift
/// class LocalEnvironment: ComposableEnvironment {
///   @Dependency(\.uuidGenerator) var uuid
/// }
/// ```
/// This exposes a `var uuid: () -> UUID` read-only property in the `LocalEnvironment`. This
/// property can then be used as any vanilla dependency.
@propertyWrapper
public struct Dependency<Value> {
  /// Alternative to ``wrappedValue`` with access to the enclosing instance.
  public static subscript<EnclosingSelf: ComposableEnvironment>(
    _enclosingInstance instance: EnclosingSelf,
    wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>,
    storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Self>
  ) -> Value {
    get {
      let wrapper = instance[keyPath: storageKeyPath]
      let keyPath = wrapper.keyPath
      let value = instance[keyPath]
      return value
    }
    set {
      fatalError("@Dependency are read-only in their ComposableEnvironment")
    }
  }

  var keyPath: WritableKeyPath<Dependencies, Value>

  /// See ``Dependency`` discussion
  public init(_ keyPath: WritableKeyPath<Dependencies, Value>) {
    self.keyPath = keyPath
  }

  @available(
    *, unavailable,
    message:
      """
  @Dependency should be used in conjunction with a `WritableKeyPath`. Please implement a setter
  part in the `Dependencies`'s computed property for this dependency.
  """
  )
  public init(_ keyPath: KeyPath<Dependencies, Value>) {
    fatalError()
  }

  @available(
    *, unavailable, message: "@Dependency should be used in a ComposableEnvironment class."
  )
  public var wrappedValue: Value {
    get { fatalError() }
    set { fatalError() }
  }
}

/// You can use this typealias if `@Dependency` is clashing with other modules offering
/// similarly named property wrappers
public typealias ComposableDependency = Dependency
