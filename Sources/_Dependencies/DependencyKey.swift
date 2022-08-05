/// Conform types to this protocol to define dependencies as ``Dependencies`` computed
/// properties.
///
/// You use this protocol like `EnvironmentKey` are used in SwiftUI. Types conforming to this
/// protocol can then be used to declare the dependency in the ``Dependencies`` namespace.
public protocol DependencyKey {
  associatedtype Value
  /// The default value returned when accessing the corresponding dependency when no value was
  /// defined by one of its parents.
  static var defaultValue: Self.Value { get }
}

/// You can use this typealias if `@DependencyKey` is clashing with other modules offering
/// similarly named protocols
public typealias ComposableDependencyKey
