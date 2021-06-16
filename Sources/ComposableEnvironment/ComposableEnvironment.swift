/// The base class of your environments.
///
/// Subclass this class to define your feature's environment. You can expose ``ComposableDependencies`` values using the
/// ``Dependency`` property wrapper and declare child environment using the ``DerivedEnvironment`` property wrapper.
///
/// For example, if you defined:
/// ```swift
/// extension ComposableDependencies {
///   var uuidGenerator: () -> UUID {…}
///   var mainQueue: AnySchedulerOf {…}
/// },
/// ```
/// you can declare the `LocalEnvironment` class, with `ChildEnvironment1` and `ChildEnvironment2` like:
/// ```swift
/// class LocalEnvironment: ComposableEnvironment {
///   @Dependency(\.uuidGenerator) var uuidGenerator
///   @Dependency(\.mainQueue) var mainQueue
///   @DerivedEnvironment<ChildEnvironment1> var child1
///   @DerivedEnvironment<ChildEnvironment2> var child2
/// }
/// ```
/// - Warning: All child environment must be themself subclasses of ``ComposableEnvironment``. If the environments chain is
/// broken, an environment will retrieve the value of a dependency from its farthest direct ascendant, or use the default value if none
/// was specificied. It will not "jump" over ascendants that are not ``ComposableEnvironment`` to retrieve the value of a dependency.
open class ComposableEnvironment {
  /// Instantiate a ``ComposableEnvironment`` instance with all dependencies sets to their defaults.
  ///
  /// After using this initializer, you can chain ``with(_:_:)`` calls to set the values of individual dependencies. These values
  /// will propagate to each child``DerivedEnvironment`` as well as their own children ``DerivedEnvironment``.
  public required init() {}

  var dependencies: ComposableDependencies = .init()

  var hasReceivedDependenciesFromParent: Bool = false
  
  var knownChildren: Set<AnyKeyPath> = []
  
  /// Use this function to set the values of a given dependency for this environment and all its descendants.
  ///
  /// Calls to this function are chainable, and you can specify any ``ComposableDependencies`` `KeyPath`, even if the current
  /// environment instance does not expose the corresponding dependency itself.
  ///
  /// For example, if you defined:
  /// ```swift
  /// extension ComposableDependencies {
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
  public func with<V>(_ keyPath: WritableKeyPath<ComposableDependencies, V>, _ value: V) -> Self {
    dependencies[keyPath: keyPath] = value
    assert(knownChildren.isEmpty, "Modifying dependencies once children DerivedEnvironments have be accessed is not supported.")
    return self
  }
}

