@_exported import struct _Dependencies.Dependencies
@_exported import protocol _Dependencies.DependencyKey

@available(*, deprecated, renamed: "Dependencies")
public typealias ComposableDependencies = Dependencies

/// This namespace is used to provide non-clashing variants to the `DependencyKey` protocol and the
/// `@Dependency` property wrapper.
public enum Compatible {}
