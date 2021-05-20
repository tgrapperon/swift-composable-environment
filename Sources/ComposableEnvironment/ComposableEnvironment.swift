import Foundation
open class ComposableEnvironment {
  public required init() {}

  @usableFromInline
  var dependencies: ComposableDependencies = .init()

  @usableFromInline
  var hasReceivedDependenciesFromParent: Bool = false
  
  @usableFromInline
  var knownChildren: Set<AnyKeyPath> = []
  
  @inlinable
  @discardableResult
  public func with<V>(_ keyPath: WritableKeyPath<ComposableDependencies, V>, _ value: V) -> Self {
    dependencies[keyPath: keyPath] = value
    assert(knownChildren.isEmpty, "Modifying dependencies once children DerivedEnvironments have be accessed is not supported.")
    return self
  }
}

