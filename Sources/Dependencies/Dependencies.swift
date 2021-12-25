/// This type acts as a namespace to reference your dependencies.
///
/// To declare a dependency, create a ``DependencyKey``, and declare a computed property in this
/// type like you would declare a custom `EnvironmentValue` in SwiftUI. For example, if
/// `UUIDGeneratorKey` is a ``DependencyKey`` with ``DependencyKey/Value`` == `() -> UUID`:
/// ```swift
/// extension Dependencies {
///   var uuidGenerator: () -> UUID {
///     get { self[UUIDGeneratorKey.self] }
///     set { self[UUIDGeneratorKey.self] = newValue }
///   }
/// }
/// ```
/// This dependency can then be referenced by its keypath `\.uuidGenerator` when invoking the
/// `Dependency` property wrapper.
public struct Dependencies {
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

  private static var sharedAliases = Set<AnyHashable>()
  private var values = [ObjectIdentifier: DependencyValue]()

  public subscript<T>(_ key: T.Type) -> T.Value where T: DependencyKey {
    get { values[ObjectIdentifier(key)]?.value as? T.Value ?? key.defaultValue }
    set { values[ObjectIdentifier(key)] = .defined(newValue) }
  }

  /// - Warning: This function is public for implementation reasons. You shouldn't have to call it
  /// when using the library.
  public mutating func _mergeFromUpstream(_ upstreamDependencies: Dependencies) {
    // We should preserve dependencies that were defined explicitely.
    for (key, value) in upstreamDependencies.values {
      guard values[key]?.isDefined != true else { continue }
      values[key] = value.inherit()
    }
  }

  /// - Warning: This function is public for implementation reasons. You shouldn't have to call it
  /// when using the library.
  public static func _new() -> Self {
    .init()
  }

  // MARK: Aliases

  public func alias<Value>(_ keyPath: WritableKeyPath<Dependencies, Value>) -> DependencyAlias<Value>? {
    for alias in Self.sharedAliases {
      if let alias = alias as? DependencyAlias<Value>, alias.aliases.contains(keyPath) {
        return alias
      }
    }
    return nil
  }

  public mutating func synchronizeAliasedDependencies<Value>
  (_ keyPath: WritableKeyPath<Dependencies, Value>) {
    guard let alias = self.alias(keyPath) else { return }
    let currentValue = self[keyPath: alias.default]
    for keyPath in alias.aliases.filter({ $0 != alias.default }) {
      self[keyPath: keyPath] = currentValue
    }
  }

  public mutating func define<Value>(_ alias: DependencyAlias<Value>) {
    remove(alias)
    _ = Self.sharedAliases.insert(alias)
  }

  public mutating func remove<Value>(_ alias: DependencyAlias<Value>) {
    if let existing = self.alias(alias.default) {
      Self.sharedAliases.remove(existing)
    }
  }

  public mutating func removeAllAliases() {
    Self.sharedAliases.removeAll()
  }
}
