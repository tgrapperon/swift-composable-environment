import Foundation
@_exported import Dependencies
/// The base class of your environments.
///
/// Subclass this class to define your feature's environment. You can expose
/// `Dependencies` values using the ``Dependency`` property wrapper and declare child
/// environment using the ``DerivedEnvironment`` property wrapper.
///
/// For example, if you define:
/// ```swift
/// extension Dependencies {
///   var uuidGenerator: () -> UUID {…}
///   var mainQueue: AnySchedulerOf {…}
/// },
/// ```
/// you can declare the `LocalEnvironment` class, with `ChildEnvironment1` and `ChildEnvironment2`
/// like:
/// ```swift
/// class LocalEnvironment: ComposableEnvironment {
///   @Dependency(\.uuidGenerator) var uuidGenerator
///   @Dependency(\.mainQueue) var mainQueue
///   @DerivedEnvironment<ChildEnvironment1> var child1
///   @DerivedEnvironment<ChildEnvironment2> var child2
/// }
/// ```
/// - Warning: All child environment must be themself subclasses of ``ComposableEnvironment``. If
/// the environments chain is broken, an environment will retrieve the value of a dependency from
/// its farthest direct ascendant, or use the default value if none was specificied. It will not
/// "jump" over ascendants that are not ``ComposableEnvironment`` to retrieve the value of a
/// dependency.
@dynamicMemberLookup
open class ComposableEnvironment {
  /// Instantiate a ``ComposableEnvironment`` instance with all dependencies sets to their defaults.
  ///
  /// After using this initializer, you can chain ``with(_:_:)`` calls to set the values of
  /// individual dependencies. These values ill propagate to each child``DerivedEnvironment`` as
  /// well as their own children ``DerivedEnvironment``.
  public required init() {}

  var dependencies: Dependencies = ._new() {
    didSet {
      // This will make any child refetch its upstream dependencies when accessed.
      upToDateDerivedEnvironments.removeAllObjects()
    }
  }
  
  var upToDateDerivedEnvironments: NSHashTable<ComposableEnvironment> = .weakObjects()
  
  @discardableResult
  func updatingFromParentIfNeeded(_ parent: ComposableEnvironment) -> Self {
    if !parent.upToDateDerivedEnvironments.contains(self) {
      // The following line updates the `environment`'s dependencies, invalidating its children
      // dependencies when it mutates its own `dependencies` property as a side effect.
      dependencies._mergeFromUpstream(parent.dependencies)
      parent.upToDateDerivedEnvironments.add(self)
    }
    return self
  }
  
  /// Use this function to set the values of a given dependency for this environment and all its
  /// descendants.
  ///
  /// Calls to this function are chainable, and you can specify any `Dependencies`'s
  /// `KeyPath`, even if the current environment instance does not expose the corresponding
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
    dependencies[keyPath: keyPath] = value
    return self
  }
  
  /// A read-write subcript to directly access a dependency from its `KeyPath` in
  /// `Dependencies`.
  public subscript<Value>(keyPath: WritableKeyPath<Dependencies, Value>) -> Value {
    get { dependencies[keyPath: keyPath] }
    set { dependencies[keyPath: keyPath] = newValue }
  }
  
  /// A read-only subcript to directly access a dependency from `Dependencies`.
  /// - Remark: This direct access can't be used to set a dependency, as it will try to go through
  /// the setter part of a ``Dependency`` property wrapper, which is not allowed yet. You can use
  ///  ``with(_:_:)`` or ``subscript(_:)`` instead.
  public subscript<Value>(dynamicMember keyPath: KeyPath<Dependencies, Value>) -> Value {
    get { dependencies[keyPath: keyPath] }
  }
}
