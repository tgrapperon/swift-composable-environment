/// Conform types to this protocol to define dependencies as ``ComposableDependencies`` computed properties.
///
/// You use this protocol like `EnvironmentKey` are used in SwiftUI. Types conforming to this protocol can then
/// be used to declare the dependency in the ``ComposableDependencies`` namespace.
public protocol DependencyKey {
  associatedtype Value
  /// The default value returned when accessing the corresponding dependency when no value was defined by
  /// one of its parents.
  static var defaultValue: Self.Value { get }
}

/// This type acts as a namespace to reference your dependencies.
///
/// To declare a dependency, create a ``DependencyKey``, and declare a computed property in this type like
/// you would declare a custom `EnvironmentValue` in SwiftUI. For example, if `UUIDGeneratorKey` is a
/// ``DependencyKey`` with ``DependencyKey/Value`` == `() -> UUID`:
///
/// ```swift
/// extension ComposableDependencies {
///   var uuidGenerator: () -> UUID {
///     get { self[UUIDGeneratorKey.self] }
///     set { self[UUIDGeneratorKey.self] = newValue }
///   }
/// }
/// ```
/// This dependency can then be referenced by its keypath `\.uuidGenerator` when invoking the ``Dependency``
/// property wrapper in some ``ComposableEnvironment`` subclass.
public struct ComposableDependencies {
  var values = [AnyHashableType: Any]()

  subscript<T>(_ key: T.Type) -> T.Value where T: DependencyKey {
    get { values[AnyHashableType(key)] as? T.Value ?? key.defaultValue }
    set { values[AnyHashableType(key)] = newValue }
  }

  mutating func mergeFromUpstream(_ upstreamDependencies: ComposableDependencies) {
    // We should preserve existing overrides
    values = values.merging(upstreamDependencies.values,
                            uniquingKeysWith: { existing, _ in existing })
  }
}
