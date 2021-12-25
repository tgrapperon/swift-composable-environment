import Dependencies
/// Use this property wrapper to declare some child ``GlobalEnvironment`` in a
/// ``GlobalEnvironment`` parent.
///
/// You only need to specify the type used and its name. You don't need to instantiate the
/// type. For example, if `ChildEnvironment` is some ``GlobalEnvironment``, you can install a
/// representant in `ParentEnvironment` as:
/// ```swift
/// struct ParentEnvironment: GlobalEnvironment {
///   @DerivedEnvironment<ChildEnvironment> var child
/// }.
/// ```
/// This exposes a `var child: ChildEnvironment` read-only property in the `ParentEnvironment`.
///
/// When using `GlobalEnvironment`, the principal use of this property wrapper is to define
/// `DependencyAlias`'s using the ``AliasBuilder`` closure from the intializers:
/// ```swift
/// struct ParentEnvironment: GlobalEnvironment {
///   @DerivedEnvironment<ChildEnvironment>(aliases: {
///     $0.alias(\.main, to: \.mainQueue)
///   }) var child
/// }
/// ```
@propertyWrapper
public final class DerivedEnvironment<Environment> where Environment: GlobalEnvironment {
  var environment: Environment
  var aliasBuilder: AliasBuilder<Environment>?
  var didSetAliases: Bool = false

  /// See ``DerivedEnvironment`` discussion
  public init(wrappedValue: Environment,
              aliases: ((inout AliasBuilder<Environment>) -> Void)? = nil) {
    self.environment = wrappedValue
    self.aliasBuilder = Self.aliasBuilder(aliases)
  }

  /// See ``DerivedEnvironment`` discussion
  public init(aliases: ((inout AliasBuilder<Environment>) -> Void)? = nil) {
    self.environment = Environment()
    self.aliasBuilder = Self.aliasBuilder(aliases)
  }

  static func aliasBuilder(_ aliases: ((inout AliasBuilder<Environment>) -> Void)?)
    -> AliasBuilder<Environment>? {
    guard let aliases = aliases else {
      return nil
    }
    var aliasBuilder = AliasBuilder<Environment>()
    aliases(&aliasBuilder)
    return aliasBuilder
  }

  public var wrappedValue: Environment {
    if !didSetAliases, let aliasBuilder = aliasBuilder {
      defer { didSetAliases = true }
      return aliasBuilder.transforming(environment)
    }
    return environment
  }
}

/// A type that is used to configure dependencies aliases when using the ``DerivedEnvironment``
/// property wrapper.
public struct AliasBuilder<Environment> where Environment: GlobalDependenciesAccessing {
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
  public func alias<Dependency>(_ dependency: WritableKeyPath<Dependencies, Dependency>,
                                to default: WritableKeyPath<Dependencies, Dependency>) -> Self {
    AliasBuilder {
      transforming($0)
        .aliasing(dependency, to: `default`)
    }
  }
}
