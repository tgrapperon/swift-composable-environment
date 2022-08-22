@_exported import ComposableDependencies
@_implementationOnly import _Dependencies
@_implementationOnly import _DependencyAliases

extension Dependencies {
  static var global: Dependencies = DependenciesUtilities.new()
  static var aliases = DependencyAliases()
}

/// A marker protocol that provides convenient access to global dependencies.
///
/// This protocol has not requirements. By conforming to it you expose some convenient methods to
/// setup and access global depencies.
public protocol GlobalDependenciesAccessing {}

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
  /// Calls to this function are chainable, and you can specify any `Dependencies`
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
    for alias in Dependencies.aliases.aliasing(with: keyPath) {
      Dependencies.global[keyPath: alias] = value
    }
    return self
  }

  /// A read-write subcript to directly access a dependency from its `KeyPath` in
  /// `Dependencies`.
  public subscript<Value>(keyPath: WritableKeyPath<Dependencies, Value>) -> Value {
    get { Dependencies.global[keyPath: Dependencies.aliases.standardAlias(for: keyPath)] }
    set {
      for alias in Dependencies.aliases.aliasing(with: keyPath) {
        Dependencies.global[keyPath: alias] = newValue
      }
    }
  }

  /// A read-only subcript to directly access a global dependency from `Dependencies`.
  /// - Remark: This direct access can't be used to set a dependency, as it will try to go through
  /// the setter part of a `Dependency` property wrapper, which is not allowed yet. You can use
  ///  ``with(_:_:)`` or ``subscript(_:)`` instead.
  public subscript<Value>(
    dynamicMember keyPath: KeyPath<Dependencies, Value>
  ) -> Value {
    Dependencies.global[keyPath: Dependencies.aliases.standardAlias(for: keyPath)]
  }

  /// Identify a dependency to another one.
  ///
  /// You can use this method to synchronize identical dependencies from different domains.
  /// For example, if you defined a main dispatch queue dependency called `.main` in one domain and
  /// `.mainQueue` in another, you can identify both dependencies using
  /// ```swift
  /// environment.aliasing(\.main, to: \.mainQueue)
  /// ```
  /// The second argument provides its default value to all aliased dependencies, and all aliased
  /// dependencies returns this default value until the value any of the aliased dependencies is
  /// set.
  ///
  /// You can set the value of any aliased dependency using any `KeyPath`:
  /// ```swift
  /// environment
  ///   .aliasing(\.main, to: \.mainQueue)
  ///   .with(\.main, DispatchQueue.main)
  /// // is equivalent to:
  /// environment
  ///   .aliasing(\.main, to: \.mainQueue)
  ///   .with(\.mainQueue, DispatchQueue.main)
  /// ```
  ///
  /// If you chain multiple aliases for the same dependency, the closest to the root is the one
  /// responsible for the default value:
  /// ```swift
  /// environment
  ///   .aliasing(\.main, to: \.mainQueue) // <- The default value will be the
  ///   .aliasing(\.uiQueue, to: \.main)   //    default value of `mainqueue`
  /// ```
  /// If dependencies aliased through `DerivedEnvironment` are aliased in the order of environment
  /// composition, with the dependency closest to the root environment providing the default value
  /// if no value is set for any aliased dependency.
  ///
  /// - Parameters:
  ///   - dependency: The `KeyPath` of the aliased dependency in `Dependencies`
  ///   - to: A `KeyPath` of another dependency in `Dependencies` that serves as a reference value.
  public func aliasing<Value>(
    _ dependency: WritableKeyPath<Dependencies, Value>,
    to default: WritableKeyPath<Dependencies, Value>
  ) -> Self {
    Dependencies.aliases.alias(dependency: dependency, to: `default`)
    return self
  }
}

extension Dependencies {
  /// Use this static method to reset all aliases you may have set between dependencies.
  /// You typically call this method during the `setUp()` method of some `XCTestCase` subclass:
  /// ```swift
  /// class SomeFeatureTests: XCTextCase {
  ///   override func setUp() {
  ///     super.setUp()
  ///     Dependencies.clearAliases()
  ///   }
  ///   // …
  /// }
  /// ```
  public static func clearAliases() {
    Self.aliases.clear()
  }
}

extension Dependencies {
  /// Use this static method to reset all global depedencies to their default values.
  /// You typically call this method during the `setUp()` method of some `XCTestCase` subclass:
  /// ```swift
  /// class SomeFeatureTests: XCTextCase {
  ///   override func setUp() {
  ///     super.setUp()
  ///     Dependencies.reset()
  ///   }
  ///   // …
  /// }
  /// ```
  public static func reset() {
    Dependencies.global = DependenciesUtilities.new()
  }
}

extension Compatible {
  /// You can use this typealias if `DependencyKey` is clashing with other modules offering
  /// a similarly named protocol.
  ///
  /// You should be able to replace:
  /// ```swift
  /// struct MainQueueKey: DependencyKey { … }
  /// ```
  /// by
  /// ```swift
  /// struct MainQueueKey: Compatible.DependencyKey { … }
  /// ```
  public typealias DependencyKey = _Dependencies.DependencyKey
}

