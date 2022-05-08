/// This type acts as a namespace to reference your dependencies.
///
/// To declare a dependency,  declare a computed property in this
/// type. For example, if
/// ```swift
/// extension Dependencies {
///   var uuidGenerator: () -> UUID {
///     get { self[\.uuidGenerator] ?? { UUID() } }
///     set { self[\.uuidGenerator] = newValue }
///   }
/// }
/// ```
/// This dependency can then be referenced by its keypath `\.uuidGenerator` when invoking the
/// `Dependency` property wrapper.
public struct Dependencies {
  /// This wrapper enum allows to distinguish dependencies that where defined explicitely for a
  /// given environment from dependencies that were inherited from their parent environment.
  fileprivate enum DependencyValue {
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

  fileprivate var deprecatedValues = [ObjectIdentifier: DependencyValue]()
	fileprivate var values = [PartialKeyPath<Dependencies>: DependencyValue]()

  fileprivate init() {}
	
	public subscript<T>(_ keyPath: WritableKeyPath<Dependencies, T>) -> T? {
    get { values[keyPath]?.value as? T }
    set { values[keyPath] = newValue.map { .defined($0) } }
	}
	
	@available(
    *, deprecated,
     message:
"""
`DependencyKey` is deprecated, use keypathes instead
"""
	)
  public subscript<T>(_ key: T.Type) -> T.Value where T: DependencyKey {
    get { deprecatedValues[ObjectIdentifier(key)]?.value as? T.Value ?? key.defaultValue }
    set { deprecatedValues[ObjectIdentifier(key)] = .defined(newValue) }
  }
}

// This type is used internally only
public enum DependenciesUtilities {
  public static func new() -> Dependencies { .init() }
  public static func merge(_ upstream: Dependencies, to dependencies: inout Dependencies) {
    // We should preserve dependencies that were defined explicitely.
    for (key, value) in upstream.values {
      guard dependencies.values[key]?.isDefined != true else { continue }
      dependencies.values[key] = value.inherit()
    }
  }
}
