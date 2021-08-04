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
  /// This wrapper enum allows to distinguish dependencies that where defined explicitely for a given environment from
  /// dependencies that were inherited from their parent environment.
  enum DependencyValue {
    case defined(Any)
    case inherited(Any)
    
    var value: Any {
      switch self {
      case let .defined(value): return value
      case let .inherited(value): return value
      }
    }
    
    func inherit() -> DependencyValue {
      switch self {
      case let .defined(value): return .inherited(value)
      case .inherited: return self
      }
    }
    
    var isDefined: Bool {
      switch self {
      case .defined: return true
      case .inherited: return false
      }
    }
  }
  
  var values = [ObjectIdentifier: DependencyValue]()

  public subscript<T>(_ key: T.Type) -> T.Value where T: DependencyKey {
    get { values[ObjectIdentifier(key)]?.value as? T.Value ?? key.defaultValue }
    set { values[ObjectIdentifier(key)] = .defined(newValue) }
  }
  
  mutating func mergeFromUpstream(_ upstreamDependencies: ComposableDependencies) {
    // We should preserve dependencies that were defined explicitely.
    for (key, value) in upstreamDependencies.values {
      guard values[key]?.isDefined != true else { continue }
      values[key] = value.inherit()
    }
  }
}
