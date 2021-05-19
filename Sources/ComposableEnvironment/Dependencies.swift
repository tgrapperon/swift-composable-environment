/// Use this protocol like you use `EnvironmentKey` in SwiftUI.
public protocol DependencyKey {
  associatedtype Value
  static var defaultValue: Self.Value { get }
}

public struct ComposableDependencies {
  @usableFromInline
  var values = [AnyHashableType: Any]()

  @inlinable
  public subscript<T>(_ key: T.Type) -> T.Value where T: DependencyKey {
    get { values[AnyHashableType(key)] as? T.Value ?? key.defaultValue }
    set { values[AnyHashableType(key)] = newValue }
  }

  @inlinable
  mutating func mergeFromUpstream(_ upstreamDependencies: ComposableDependencies) {
    // We should preserve existing overrides
    values = values.merging(upstreamDependencies.values,
                            uniquingKeysWith: { existing, _ in existing })
  }
}
