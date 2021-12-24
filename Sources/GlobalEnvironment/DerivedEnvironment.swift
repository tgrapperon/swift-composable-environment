/// Use this property wrapper to declare some child ``GlobalEnvironment`` in a
/// ``GlobalEnvironment`` parent.
///
/// You only need to specify the type used and its name. You don't need to instantiate the
/// type. For example, if `ChildEnvironment` is some ``GlobalEnvironment``, you can install a
/// representant in `ParentEnvironment` as:
/// ```swift
/// struct ParentEnvironment: GlobalEnvironment {
///   @DerivedEnvironment<ChildEnvironment> var child
/// }.
/// ```
/// This exposes a `var child: ChildEnvironment` read-only property in the `ParentEnvironment`.
/// - Warning: This property wrapper is only provided to maintain source compatibility when migrating
/// from `ComposableEnvironment` to `GlobalEnvironment`. It has no practical use in projects using
/// `GlobalEnvironment` from the beginning, as `Environment`-less `Reducer`'s pullbacks don't need
/// contextual information to work when using `GlobalEnvironment`.
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
