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
@dynamicMemberLookup
open class ComposableEnvironment {
  /// Instantiate a ``ComposableEnvironment`` instance with all dependencies sets to their defaults.
  ///
  /// After using this initializer, you can chain ``with(_:_:)`` calls to set the values of individual dependencies. These values
  /// will propagate to each child``DerivedEnvironment`` as well as their own children ``DerivedEnvironment``.
  public required init() {}

  var dependencies: ComposableDependencies = .init() {
    didSet {
      // This will make any child refetch its upstream dependencies when accessed.
      knownChildren.removeAll()
    }
  }
      
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
    return self
  }
  
  /// A read-write subcript to directly access a dependency from its `KeyPath` in ``ComposableDependencies``.
  public subscript<Value>(keyPath: WritableKeyPath<ComposableDependencies, Value>) -> Value {
    get { dependencies[keyPath: keyPath] }
    set { dependencies[keyPath: keyPath] = newValue }
  }
  
  /// A read-only subcript to directly access a dependency from ``ComposableDependencies``.
  /// - Remark: This direct access can't be used to set a dependency, as it will try to go through a the setter part of a ``Dependency``
  /// property wrapper, which is not allowed yet. You can use ``with(_:_:)`` or ``subscript(_:)`` instead.
  public subscript<Value>(dynamicMember keyPath: KeyPath<ComposableDependencies, Value>) -> Value {
    get { dependencies[keyPath: keyPath] }
  }
}
