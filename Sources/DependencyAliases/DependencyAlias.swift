import Dependencies

public struct DependencyAlias<Value>: Hashable {
  public let `default`: WritableKeyPath<Dependencies, Value>
  var aliases: Set<WritableKeyPath<Dependencies, Value>> = []
  
  public init(_ aliased: WritableKeyPath<Dependencies, Value>, to default: WritableKeyPath<Dependencies, Value>) {
    self.default = `default`
    self.aliases = [aliased, `default`]
  }
  
  public func appending(_ alias: DependencyAlias<Value>) -> DependencyAlias {
    var new = self
    new.aliases.formUnion(alias.aliases)
    return new
  }
}
