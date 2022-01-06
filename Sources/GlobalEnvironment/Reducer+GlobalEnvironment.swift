import ComposableArchitecture

extension Reducer where Environment: GlobalEnvironment {
  /// Transforms a reducer that works on local state, action, and environment into one that works on
  /// global state, action and environment when the local environment is some ``GlobalEnvironment``.
  /// It accomplishes this by providing 2 transformations to the method:
  ///
  ///   * A writable key path that can get/set a piece of local state from the global state.
  ///   * A case path that can extract/embed a local action into a global action.
  ///
  /// Because the environment is ``GlobalEnvironment``, its lifecycle is automatically managed by
  /// the library.
  /// For more information about this reducer, see the discussion about the equivalent function
  /// using unbounded environments in `swift-composable-architecture`.
  ///
  /// - Parameters:
  ///   - toLocalState: A key path that can get/set `State` inside `GlobalState`.
  ///   - toLocalAction: A case path that can extract/embed `Action` from `GlobalAction`.
  /// - Returns: A reducer that works on `GlobalState`, `GlobalAction`, `GlobalEnvironment`.
  public func pullback<GlobalState, GlobalAction, GlobalEnvironment>(
    state toLocalState: WritableKeyPath<GlobalState, State>,
    action toLocalAction: CasePath<GlobalAction, Action>
  ) -> Reducer<GlobalState, GlobalAction, GlobalEnvironment> {
    let local = Environment()
    return pullback(
      state: toLocalState,
      action: toLocalAction,
      environment: { _ in local }
    )
  }

  /// Transforms a reducer that works on local state, action, and environment into one that works on
  /// global state, action and environmentwhen the local environment is  a ``GlobalEnvironment``.
  ///
  /// It accomplishes this by providing 2 transformations to the method:
  ///
  ///   * A case path that can extract/embed a piece of local state from the global state, which is
  ///     typically an enum.
  ///   * A case path that can extract/embed a local action into a global action.
  ///
  /// Because the environment is ``GlobalEnvironment``, its lifecycle is automatically managed by
  /// the library.
  /// For more information about this reducer, see the discussion about the equivalent function using
  /// unbounded environments in `swift-composable-architecture`.
  ///
  /// - Parameters:
  ///   - toLocalState: A case path that can extract/embed `State` from `GlobalState`.
  ///   - toLocalAction: A case path that can extract/embed `Action` from `GlobalAction`.
  /// - Returns: A reducer that works on `GlobalState`, `GlobalAction`, `GlobalEnvironment`.
  public func pullback<GlobalState, GlobalAction, GlobalEnvironment>(
    state toLocalState: CasePath<GlobalState, State>,
    action toLocalAction: CasePath<GlobalAction, Action>,
    breakpointOnNil: Bool = true,
    _ file: StaticString = #file,
    _ line: UInt = #line
  ) -> Reducer<GlobalState, GlobalAction, GlobalEnvironment> {
    let local = Environment()
    return pullback(
      state: toLocalState,
      action: toLocalAction,
      environment: { _ in local },
      breakpointOnNil: breakpointOnNil
    )
  }

  /// A version of ``pullback(state:action)`` that transforms a reducer that works on
  /// an element into one that works on an identified array of elements, when the local environment
  /// is some ``GlobalEnvironment``.
  ///
  /// For more information about this reducer, see the discussion about the equivalent function
  /// using unbounded environments in `swift-composable-architecture`.
  ///
  /// - Parameters:
  ///   - toLocalState: A key path that can get/set a collection of `State` elements inside
  ///     `GlobalState`.
  ///   - toLocalAction: A case path that can extract/embed `(Collection.Index, Action)` from
  ///     `GlobalAction`.
  ///   - breakpointOnNil: Raises `SIGTRAP` signal when an action is sent to the reducer but the
  ///     identified array does not contain an element with the action's identifier. This is
  ///     generally considered a logic error, as a child reducer cannot process a child action
  ///     for unavailable child state.
  /// - Returns: A reducer that works on `GlobalState`, `GlobalAction`, `GlobalEnvironment`.
  public func forEach<GlobalState, GlobalAction, GlobalEnvironment, ID>(
    state toLocalState: WritableKeyPath<GlobalState, IdentifiedArray<ID, State>>,
    action toLocalAction: CasePath<GlobalAction, (ID, Action)>,
    breakpointOnNil: Bool = true,
    _ file: StaticString = #file,
    _ line: UInt = #line
  ) -> Reducer<GlobalState, GlobalAction, GlobalEnvironment> {
    let local = Environment()
    return forEach(
      state: toLocalState,
      action: toLocalAction,
      environment: { _ in local },
      breakpointOnNil: breakpointOnNil
    )
  }

  /// A version of ``pullback(state:action:environment:)`` that transforms a reducer that works on
  /// an element into one that works on a dictionary of element values, when the local environment
  /// is some ``GlobalEnvironment``.
  ///
  /// For more information about this reducer, see the discussion about the equivalent function
  /// using unbounded environments in `swift-composable-architecture`.
  ///
  /// - Parameters:
  ///   - toLocalState: A key path that can get/set a dictionary of `State` values inside
  ///     `GlobalState`.
  ///   - toLocalAction: A case path that can extract/embed `(Key, Action)` from `GlobalAction`.
  ///   - breakpointOnNil: Raises `SIGTRAP` signal when an action is sent to the reducer but the
  ///     identified array does not contain an element with the action's identifier. This is
  ///     generally considered a logic error, as a child reducer cannot process a child action
  ///     for unavailable child state.
  /// - Returns: A reducer that works on `GlobalState`, `GlobalAction`, `GlobalEnvironment`.
  public func forEach<GlobalState, GlobalAction, GlobalEnvironment, Key>(
    state toLocalState: WritableKeyPath<GlobalState, [Key: State]>,
    action toLocalAction: CasePath<GlobalAction, (Key, Action)>,
    breakpointOnNil: Bool = true,
    _ file: StaticString = #file,
    _ line: UInt = #line
  ) -> Reducer<GlobalState, GlobalAction, GlobalEnvironment> {
    let local = Environment()
    return forEach(
      state: toLocalState,
      action: toLocalAction,
      environment: { _ in local },
      breakpointOnNil: breakpointOnNil
    )
  }
}
