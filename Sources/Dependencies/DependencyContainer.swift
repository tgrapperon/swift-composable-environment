public struct DependencyContainer {
  /// This wrapper enum allows to distinguish dependencies that where defined explicitely for a
  /// given environment from dependencies that were inherited from their parent environment.
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
  
  public mutating func _mergeFromUpstream(_ upstreamDependencies: DependencyContainer) {
    // We should preserve dependencies that were defined explicitely.
    for (key, value) in upstreamDependencies.values {
      guard values[key]?.isDefined != true else { continue }
      values[key] = value.inherit()
    }
  }
  
  public static func _new() -> Self {
    .init()
  }
}
