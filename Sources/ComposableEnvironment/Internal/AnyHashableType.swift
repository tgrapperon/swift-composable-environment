struct AnyHashableType: Hashable {
  private var type: Any
  private var isEqualTo: (AnyHashableType) -> Bool
  private var hashInto: (inout Hasher) -> Void

  init<T>(_ type: T.Type) {
    self.type = type
    let description = String(describing: T.self)
    if type is AnyClass {
      // We can't compare types with `is` for classes as B:A is A.
      // Fallback to the description which is also used to hash.
      isEqualTo = { description == String(describing: $0.type) }
    } else {
      isEqualTo = { $0.type is T.Type }
    }
    hashInto = { $0.combine(description) }
  }

  func hash(into hasher: inout Hasher) {
    hashInto(&hasher)
  }

  static func == (lhs: AnyHashableType, rhs: AnyHashableType) -> Bool {
    lhs.isEqualTo(rhs)
  }
}
