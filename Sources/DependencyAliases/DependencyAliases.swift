public struct DependencyAliases {
  var aliases: [AnyHashable: AnyHashable] = [:]

  public init() {}

  public mutating func clear() {
    aliases.removeAll()
  }

  public mutating func alias<T>(dependency: T, to default: T) where T: Hashable {
    if let existingForDefault = aliases[`default`] as? T {
      aliases[dependency] = existingForDefault
    } else {
      aliases[dependency] = `default`
    }
  }

  public func canonicalAlias<T>(for dependency: T) -> T where T: Hashable {
    orbit(for: dependency).last ?? dependency
  }

  func orbit<T>(for dependency: T) -> [T] where T: Hashable {
    var orbit = [dependency]
    var dependency = dependency
    while let alias = aliases[dependency] as? T {
      guard !orbit.contains(alias) else { break }
      orbit.append(alias)
      dependency = alias
    }
    return orbit
  }

  public func preimage<T>(for dependency: T) -> Set<T> where T: Hashable {
    if aliases.isEmpty { return [dependency] }
    let canonical = self.canonicalAlias(for: dependency)
    return Set(
        aliases
        .filter { $0.key is T }
        .map { orbit(for: $0.key as! T) }
        .filter { $0.contains(canonical) }
        .flatMap { $0 }
    )
  }
}
