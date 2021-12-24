@_exported import Dependencies

extension Dependencies {
  static var global: Dependencies = ._new()
}

/// A marker protocol that provides convenient access to global dependencies.
///
/// This protocol has not requirements. By conforming to it you expose some convenient methods to
/// setup and access global depencies.
public protocol GlobalDependenciesAccessing {}

extension GlobalDependenciesAccessing {
  /// An accessor to the global dependencies.
  public var globalDependencies: Dependencies { Dependencies.global }
}

/// A protocol characterizing a type that has no local dependencies.
///
/// If your environment has no local dependencies, that is, if all dependencies are global, you can
/// make it conform to ``GlobalEnvironment``. This opens access to environment-less pullbacks on
/// Reducers using this environment.
///
/// The only requirement is to provide an argument-less initializer. A default implementation is
/// provided.
public protocol GlobalEnvironment: GlobalDependenciesAccessing {
  /// An argument-less initializer.
  init()
}

extension GlobalDependenciesAccessing {
  /// Use this function to set the values of a given dependency for the global environment.
  ///
  /// Calls to this function are chainable, and you can specify any ``Dependencies``
  /// `KeyPath`, even if the current environment does not expose the corresponding
  /// dependency itself.
  ///
  /// For example, if you define:
  /// ```swift
  /// extension Dependencies {
  ///   var uuidGenerator: () -> UUID {…}
  ///   var mainQueue: AnySchedulerOf {…}
  /// },
  /// ```
  /// you can set their values in a `LocalEnvironment` instance and all its descendants like:
  /// ```swift
  /// LocalEnvironment()
  ///   .with(\.uuidGenerator, { UUID() })
  ///   .with(\.mainQueue, .main)
  /// ```
  @discardableResult
  public func with<V>(_ keyPath: WritableKeyPath<Dependencies, V>, _ value: V) -> Self {
    Dependencies.global[keyPath: keyPath] = value
    return self
  }
  
  /// A read-write subcript to directly access a dependency from its `KeyPath` in
  /// `Dependencies`.
  public subscript<Value>(keyPath: WritableKeyPath<Dependencies, Value>) -> Value {
    get { Dependencies.global[keyPath: keyPath] }
    set { Dependencies.global[keyPath: keyPath] = newValue }
  }
  
  /// A read-only subcript to directly access a global dependency from `Dependencies`.
  /// - Remark: This direct access can't be used to set a dependency, as it will try to go through
  /// the setter part of a `Dependency` property wrapper, which is not allowed yet. You can use
  ///  ``with(_:_:)`` or ``subscript(_:)`` instead.
  public subscript<Value>(dynamicMember keyPath: KeyPath<Dependencies, Value>) -> Value {
    get { Dependencies.global[keyPath: keyPath] }
  }
}
