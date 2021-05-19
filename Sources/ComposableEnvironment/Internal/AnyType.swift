@usableFromInline
struct AnyHashableType: Hashable {
  private var type: Any
  private var isEqualTo: (AnyHashableType) -> Bool
  private var hashInto: (inout Hasher) -> Void

  @usableFromInline
  init<T>(_ type: T.Type) {
    self.type = type
    isEqualTo = { $0.type is T.Type }
    hashInto = { $0.combine(String(describing: T.self)) }
  }

  @usableFromInline
  func hash(into hasher: inout Hasher) {
    hashInto(&hasher)
  }

  @usableFromInline
  static func == (lhs: AnyHashableType, rhs: AnyHashableType) -> Bool {
    lhs.isEqualTo(rhs)
  }
}
