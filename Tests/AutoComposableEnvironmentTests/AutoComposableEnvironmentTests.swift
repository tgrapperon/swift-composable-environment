@testable import AutoComposableEnvironment
import ComposableArchitecture
import XCTest

struct IntKey: DependencyKey {
  static var defaultValue: Int { 1 }
}

extension ComposableDependencies {
  var int: Int {
    get { self[IntKey.self] }
    set { self[IntKey.self] = newValue }
  }
}

final class ComposableEnvironmentTests: XCTestCase {
  func testPullbackWithKeyPath() {
    enum Action {
      case action
    }

    class RootEnvironment: AutoComposableEnvironment {}
    class DerivedEnvironment1: AutoComposableEnvironment {}
    class DerivedEnvironment2: AutoComposableEnvironment {}

    let reducer2 = Reducer<Int, Action, DerivedEnvironment2> {
      state, _, environment in
      state = environment.int
      return .none
    }

    let reducer1 = Reducer<Int, Action, DerivedEnvironment1>.combine(
      reducer2.pullback(state: \.self, action: /.self)
    )

    let rootReducer = Reducer<Int, Action, RootEnvironment>.combine(
      reducer1.pullback(state: \.self, action: /.self)
    )

    let store = TestStore(
      initialState: 0,
      reducer: rootReducer,
      environment: .init()
        .with(\.int, 2)
    )

    store.send(.action) { $0 = 2 }
  }

  func testPullbackWithCasePath() {
    enum State: Equatable {
      case int(Int)
    }
    enum Action {
      case action
    }

    class RootEnvironment: AutoComposableEnvironment {}
    class DerivedEnvironment1: AutoComposableEnvironment {}
    class DerivedEnvironment2: AutoComposableEnvironment {}

    let reducer2 = Reducer<State, Action, DerivedEnvironment2> {
      state, _, environment in
      state = .int(environment.int)
      return .none
    }

    let reducer1 = Reducer<State, Action, DerivedEnvironment1>.combine(
      reducer2.pullback(state: /.self, action: /.self)
    )

    let rootReducer = Reducer<State, Action, RootEnvironment>.combine(
      reducer1.pullback(state: /.self, action: /.self)
    )

    let store = TestStore(
      initialState: .int(0),
      reducer: rootReducer,
      environment: .init()
        .with(\.int, 2)
    )

    store.send(.action) { $0 = .int(2) }
  }

  func testForEachIdentifiedArray() {
    enum Action {
      case action
    }

    class RootEnvironment: AutoComposableEnvironment {}
    class DerivedEnvironment1: AutoComposableEnvironment {}
    class DerivedEnvironment2: AutoComposableEnvironment {}

    struct Value: Identifiable, Equatable {
      var id: String
      var int: Int
    }

    let reducer2 = Reducer<IdentifiedArrayOf<Value>, Action, DerivedEnvironment2> {
      state, _, environment in
      for index in state.indices {
        state.update(.init(id: state[index].id, int: environment.int), at: index)
      }
      return .none
    }

    let reducer1 = Reducer<IdentifiedArrayOf<Value>, Action, DerivedEnvironment1>.combine(
      reducer2.pullback(state: \.self, action: /.self)
    )

    let rootReducer = Reducer<IdentifiedArrayOf<Value>, Action, RootEnvironment>.combine(
      reducer1.pullback(state: \.self, action: /.self)
    )

    let store = TestStore(
      initialState: .init(uniqueElements: [
        .init(id: "A", int: 0),
        .init(id: "B", int: 3),
      ]),
      reducer: rootReducer,
      environment: .init()
        .with(\.int, 2)
    )

    store.send(.action) {
      $0 = .init(uniqueElements: [
        .init(id: "A", int: 2),
        .init(id: "B", int: 2),
      ])
    }
  }

  func testForEachDictionary() {
    enum Action {
      case action
    }
    class RootEnvironment: AutoComposableEnvironment {}
    class DerivedEnvironment1: AutoComposableEnvironment {}
    class DerivedEnvironment2: AutoComposableEnvironment {}

    let reducer2 = Reducer<[String: Int], Action, DerivedEnvironment2> {
      state, _, environment in
      for key in state.keys {
        state[key] = environment.int
      }
      return .none
    }

    let reducer1 = Reducer<[String: Int], Action, DerivedEnvironment1>.combine(
      reducer2.pullback(state: \.self, action: /.self)
    )

    let rootReducer = Reducer<[String: Int], Action, RootEnvironment>.combine(
      reducer1.pullback(state: \.self, action: /.self)
    )

    let store = TestStore(
      initialState: [
        "A": 0,
        "B": 3,
      ],
      reducer: rootReducer,
      environment: .init()
        .with(\.int, 2)
    )

    store.send(.action) {
      $0 = [
        "A": 2,
        "B": 2,
      ]
    }
  }
}
