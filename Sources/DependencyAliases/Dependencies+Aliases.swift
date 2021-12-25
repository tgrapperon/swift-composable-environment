import Dependencies

extension Dependencies {
  private static var sharedAliases = Set<AnyHashable>()

  public func alias<Value>(_ keyPath: WritableKeyPath<Dependencies, Value>) -> DependencyAlias<Value>? {
    for alias in Self.sharedAliases {
      if let alias = alias as? DependencyAlias<Value>, alias.aliases.contains(keyPath) {
        return alias
      }
    }
    return nil
  }

  public mutating func synchronizeAliasedDependencies<Value>
  (_ keyPath: WritableKeyPath<Dependencies, Value>) {
    guard let alias = self.alias(keyPath) else { return }
    let currentValue = self[keyPath: alias.default]
    for keyPath in alias.aliases.filter({ $0 != alias.default }) {
      self[keyPath: keyPath] = currentValue
    }
  }

  public mutating func define<Value>(_ alias: DependencyAlias<Value>) {
    remove(alias)
    _ = Self.sharedAliases.insert(alias)
  }

  public mutating func remove<Value>(_ alias: DependencyAlias<Value>) {
    if let existing = self.alias(alias.default) {
      Self.sharedAliases.remove(existing)
    }
  }

  public mutating func removeAllAliases() {
    Self.sharedAliases.removeAll()
  }
}
