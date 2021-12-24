/// Use this property wrapper to declare depencies in a ``ComposableEnvironment`` subclass.
///
/// You reference the dependency by its `KeyPath` originating from  ``ComposableDependencies``, and
/// you declare its name in the local environment. The dependency should not be instantiated, as it
/// is either inherited from a ``ComposableEnvironment`` parent, or installed with
/// ``ComposableEnvironment/with(_:_:)``.
///
/// For example, if the dependency is declared as:
/// ```swift
/// extension ComposableDependencies {
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
      let value = instance.dependencies[keyPath: keyPath]
      return value
    }
    set {
      fatalError("@Dependency are read-only in their ComposableEnvironment")
    }
  }

  var keyPath: KeyPath<ComposableDependencies, Value>

  /// See ``Dependency`` discussion
  public init(_ keyPath: KeyPath<ComposableDependencies, Value>) {
    self.keyPath = keyPath
  }
  
  @available(*, unavailable, message: "@Dependency should be used in a ComposableEnvironment class.")
  public var wrappedValue: Value {
    get { fatalError() }
    set { fatalError() }
  }
}

/// Use this property wrapper to declare depencies in a ``ComposableEnvironment`` subclass.
///
/// You reference the dependency by its `KeyPath` originating from  ``ComposableDependencies``, and
/// you declare its name in the local environment. The dependency should not be instantiated, as it
/// is either inherited from a ``ComposableEnvironment`` parent, or installed with
/// ``ComposableEnvironment/with(_:_:)``.
///
/// For example, if the dependency is declared as:
/// ```swift
/// extension ComposableDependencies {
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
public struct _Dependency<Value> {
  /// Alternative to ``wrappedValue`` with access to the enclosing instance.
  public static subscript<EnclosingSelf: ComposableEnvironment>(
    _enclosingInstance instance: EnclosingSelf,
    wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>,
    storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Self>
  ) -> Value {
    get {
      let wrapper = instance[keyPath: storageKeyPath]
      let keyPath = wrapper.keyPath
      let value = instance._dependencies[keyPath: keyPath]
      return value
    }
    set {
      fatalError("@Dependency are read-only in their ComposableEnvironment")
    }
  }
  
  var keyPath: KeyPath<_ComposableDependencies, Value>
  
  /// See ``Dependency`` discussion
  public init(_ keyPath: KeyPath<_ComposableDependencies, Value>) {
    self.keyPath = keyPath
  }
  
  @available(*, unavailable, message: "@Dependency should be used in a ComposableEnvironment class.")
  public var wrappedValue: Value {
    get { fatalError() }
    set { fatalError() }
  }
}
