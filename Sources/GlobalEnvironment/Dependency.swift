/// Use this property wrapper to access global depencies anywhere.
///
/// You reference the dependency by its `KeyPath` originating from  `Dependencies`, and
/// you declare its name in the local environment. The dependency should not be instantiated.
///
/// For example, if the dependency is declared as:
/// ```swift
/// extension Dependencies {
///   var uuidGenerator: () -> UUID {
///     get { self[UUIDGeneratorKey.self] }
///     set { self[UUIDGeneratorKey.self] = newValue }
///   }
/// },
/// ```
/// you can install it in `LocalEnvironment` like:
/// ```swift
/// struct LocalEnvironment {
///   @Dependency(\.uuidGenerator) var uuid
/// }
/// ```
/// This exposes a `var uuid: () -> UUID` read-only property in the `LocalEnvironment`. This
/// property can then be used as any vanilla dependency.
@propertyWrapper
public struct Dependency<Value> {
  var keyPath: KeyPath<Dependencies, Value>

  /// See ``Dependency`` discussion
  public init(_ keyPath: KeyPath<Dependencies, Value>) {
    self.keyPath = keyPath
  }
  
  public var wrappedValue: Value {
    Dependencies.global[keyPath: Dependencies.aliases.canonicalAlias(for: keyPath)]
  }
}
