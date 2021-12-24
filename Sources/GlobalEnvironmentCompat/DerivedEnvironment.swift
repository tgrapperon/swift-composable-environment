/// Use this property wrapper to declare child ``ComposableEnvironment`` in a
/// ``ComposableEnvironment`` subclass.
///
/// You only need to specify the subclass used and its name. You don't need to instantiate the
/// subclass. For example, if `ChildEnvironment` is a ``ComposableEnvironment`` subclass, you can
/// install a representant in `ParentEnvironment` as:
/// ```swift
/// class ParentEnvironment: ComposableEnvironment {
///   @DerivedEnvironment<ChildEnvironment> var child
/// }.
/// ```
/// This exposes a `var child: ChildEnvironment` read-only property in the `ParentEnvironment`.
/// This child environment inherits the current dependencies of all its ancestor. They can be
/// exposed using the ``Dependency`` property wrapper.
@propertyWrapper
public final class DerivedEnvironment<Value> where Value: GlobalEnvironment {

  var environment: Value?

  /// See ``DerivedEnvironment`` discussion
  public init(wrappedValue: Value) {
    self.environment = wrappedValue
  }

  /// See ``DerivedEnvironment`` discussion
  public init() {
    self.environment = nil
  }

  public var wrappedValue: Value {
    environment ?? Value.init()
  }
}
