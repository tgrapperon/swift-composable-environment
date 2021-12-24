@_exported import GlobalEnvironment
/// This type acts as a namespace to reference your dependencies.
///
/// To declare a dependency, create a ``DependencyKey``, and declare a computed property in this
/// type like you would declare a custom `EnvironmentValue` in SwiftUI. For example, if
/// `UUIDGeneratorKey` is a ``DependencyKey`` with ``DependencyKey/Value`` == `() -> UUID`:
/// ```swift
/// extension ComposableDependencies {
///   var uuidGenerator: () -> UUID {
///     get { self[UUIDGeneratorKey.self] }
///     set { self[UUIDGeneratorKey.self] = newValue }
///   }
/// }
/// ```
/// This dependency can then be referenced by its keypath `\.uuidGenerator` when invoking the
/// ``Dependency`` property wrapper in some ``ComposableEnvironment`` subclass.
public typealias ComposableDependencies = Dependencies
