import Foundation
open class ComposableEnvironment {
  public required init() {}

  var dependencies: ComposableDependencies = .init()

  var hasReceivedDependenciesFromParent: Bool = false
  
  var knownChildren: Set<AnyKeyPath> = []
  
  @discardableResult
  public func with<V>(_ keyPath: WritableKeyPath<ComposableDependencies, V>, _ value: V) -> Self {
    dependencies[keyPath: keyPath] = value
    assert(knownChildren.isEmpty, "Modifying dependencies once children DerivedEnvironments have be accessed is not supported.")
    return self
  }
}

