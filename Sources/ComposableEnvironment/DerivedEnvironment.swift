import ComposableDependencies

/// Use this property wrapper to declare child ``ComposableEnvironment`` in a
/// ``ComposableEnvironment`` subclass.
///
/// You only need to specify the subclass used and its name. You don't need to instantiate the
/// subclass. For example, if `ChildEnvironment` is a ``ComposableEnvironment`` subclass, you can
/// install a representant in `ParentEnvironment` as:
/// ```swift
/// class ParentEnvironment: ComposableEnvironment {
///   @DerivedEnvironment<ChildEnvironment> var child
/// }.
/// ```
/// This exposes a `var child: ChildEnvironment` read-only property in the `ParentEnvironment`.
/// This child environment inherits the current dependencies of all its ancestor. They can be
/// exposed using the ``Dependency`` property wrapper.
///
/// You can also use this property wrapper is to define `DependencyAlias`'s using the
/// ``AliasBuilder`` closure from the intializers:
/// ```swift
/// struct ParentEnvironment: GlobalEnvironment {
///   @DerivedEnvironment<ChildEnvironment>(aliases: {
///     $0.alias(\.main, to: \.mainQueue)
///   }) var child
/// }
/// ```
@propertyWrapper
public final class DerivedEnvironment<Value> where Value: ComposableEnvironment {
  /// Alternative to ``wrappedValue`` with access to the enclosing instance.
  public static subscript<EnclosingSelf: ComposableEnvironment>(
    _enclosingInstance instance: EnclosingSelf,
    wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>,
    storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, DerivedEnvironment>
  ) -> Value {
    get {
      let environment = instance[keyPath: storageKeyPath]
        .environment
      if !instance[keyPath: storageKeyPath].didSetAliases,
         let aliasBuilder = instance[keyPath: storageKeyPath].aliasBuilder {
        defer { instance[keyPath: storageKeyPath].didSetAliases = true }
        return aliasBuilder.transforming(environment)
      }

      return environment.updatingFromParentIfNeeded(instance)
    }
    set {
      fatalError("@DerivedEnvironments are read-only in their parent")
    }
  }

  lazy var environment: Value = .init()
  
  var aliasBuilder: AliasBuilder<Value>?
  var didSetAliases: Bool = false

  /// See ``DerivedEnvironment`` discussion
  public init(wrappedValue: Value, aliases: ((AliasBuilder<Value>) -> AliasBuilder<Value>)? = nil) {
    self.environment = wrappedValue
    self.aliasBuilder = aliases.map { $0(.init()) }
  }

  /// See ``DerivedEnvironment`` discussion
  public init(aliases: ((AliasBuilder<Value>) -> AliasBuilder<Value>)? = nil) {
    self.aliasBuilder = aliases.map { $0(.init()) }
  }

  @available(*, unavailable,
             message: "@DerivedEnvironment should be used in a ComposableEnvironment class.")
  public var wrappedValue: Value {
    get { fatalError() }
    set { fatalError() }
  }
}

/// A type that is used to configure dependencies aliases when using the ``DerivedEnvironment``
/// property wrapper.
public struct AliasBuilder<Environment> where Environment: ComposableEnvironment {
  var transforming: (Environment) -> Environment = { $0 }

  /// Add a new dependency alias to the builder
  ///
  /// You can chain calls to define multiple aliases:
  /// ```swift
  /// builder
  ///   .alias(\.main, to: \.mainQueue)
  ///   .alias(\.uuid, to: \.idGenerator)
  ///   …
  /// ```
  ///  See the discussion at `DependenciesAccessing.aliasing(:to:)` for more information.
  ///
  /// - Parameters:
  ///   - dependency: The `KeyPath` of the aliased dependency in `Dependencies`
  ///   - to: A `KeyPath` of another dependency in `Dependencies` that serves as a reference value.
  public func alias<Dependency>(
    _ dependency: WritableKeyPath<Dependencies, Dependency>,
    to default: WritableKeyPath<Dependencies, Dependency>
  ) -> Self {
    AliasBuilder {
      transforming($0)
        .aliasing(dependency, to: `default`)
    }
  }
}
