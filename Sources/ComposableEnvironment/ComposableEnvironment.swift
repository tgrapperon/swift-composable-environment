open class ComposableEnvironment {
  public required init() {}

  @usableFromInline
  var dependencies: ComposableDependencies = .init()

  @inlinable
  public func with<V>(_ keyPath: WritableKeyPath<ComposableDependencies, V>, _ value: V) -> Self {
    dependencies[keyPath: keyPath] = value
    return self
  }
}
