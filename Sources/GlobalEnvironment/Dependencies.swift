@_exported import Dependencies

/// This type acts as a namespace to reference your global dependencies.
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
/// This dependency can then be referenced by its keypath `\.uuidGenerator` when installing a
/// ``Dependency`` property wrapper.
public typealias Dependencies = DependencyContainer

extension Dependencies {
  static var global: Dependencies = ._new()
}
