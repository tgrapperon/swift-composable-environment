@testable import ComposableEnvironment
import ComposableDependencies
import ComposableArchitecture
import XCTest

fileprivate struct IntKey: DependencyKey {
  static var defaultValue: Int { 1 }
}

fileprivate extension Dependencies {
  var int: Int {
    get { self[IntKey.self] }
    set { self[IntKey.self] = newValue }
  }
}

final class ReducerAdditionsTests: XCTestCase {
  func testPullbackWithKeyPath() {
    enum Action {
      case action
    }

    class First: ComposableEnvironment {}
    class Second: ComposableEnvironment {}
    class Third: ComposableEnvironment {}

    let thirdReducer = Reducer<Int, Action, Third> {
      state, _, environment in
      state = environment.int
      return .none
    }

    let secondReducer = Reducer<Int, Action, Second>.combine(
      thirdReducer.pullback(state: \.self, action: /.self)
    )

    let firstReducer = Reducer<Int, Action, First>.combine(
      secondReducer.pullback(state: \.self, action: /.self)
    )

    let store = TestStore(
      initialState: 0,
      reducer: firstReducer,
      environment: First() // Swift ≥ 5.4 can use .init()
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

    class First: ComposableEnvironment {}
    class Second: ComposableEnvironment {}
    class Third: ComposableEnvironment {}

    let thirdReducer = Reducer<State, Action, Third> {
      state, _, environment in
      state = .int(environment.int)
      return .none
    }

    let secondReducer = Reducer<State, Action, Second>.combine(
      thirdReducer.pullback(state: /.self, action: /.self)
    )

    let firstReducer = Reducer<State, Action, First>.combine(
      secondReducer.pullback(state: /.self, action: /.self)
    )

    let store = TestStore(
      initialState: .int(0),
      reducer: firstReducer,
      environment: First() // Swift ≥ 5.4 can use .init()
        .with(\.int, 2)
    )

    store.send(.action) { $0 = .int(2) }
  }

  func testForEachIdentifiedArray() {
    enum Action {
      case action
    }

    class First: ComposableEnvironment {}
    class Second: ComposableEnvironment {}
    class Third: ComposableEnvironment {}

    struct Value: Identifiable, Equatable {
      var id: String
      var int: Int
    }

    let thirdReducer = Reducer<IdentifiedArrayOf<Value>, Action, Third> {
      state, _, environment in
      for index in state.indices {
        state.update(.init(id: state[index].id, int: environment.int), at: index)
      }
      return .none
    }

    let secondReducer = Reducer<IdentifiedArrayOf<Value>, Action, Second>.combine(
      thirdReducer.pullback(state: \.self, action: /.self)
    )

    let firstReducer = Reducer<IdentifiedArrayOf<Value>, Action, First>.combine(
      secondReducer.pullback(state: \.self, action: /.self)
    )

    let store = TestStore(
      initialState: .init(uniqueElements: [
        .init(id: "A", int: 0),
        .init(id: "B", int: 3),
      ]),
      reducer: firstReducer,
      environment: First() // Swift ≥ 5.4 can use .init()
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
    class First: ComposableEnvironment {}
    class Second: ComposableEnvironment {}
    class Third: ComposableEnvironment {}

    let thirdReducer = Reducer<[String: Int], Action, Third> {
      state, _, environment in
      for key in state.keys {
        state[key] = environment.int
      }
      return .none
    }

    let secondReducer = Reducer<[String: Int], Action, Second>.combine(
      thirdReducer.pullback(state: \.self, action: /.self)
    )

    let firstReducer = Reducer<[String: Int], Action, First>.combine(
      secondReducer.pullback(state: \.self, action: /.self)
    )

    let store = TestStore(
      initialState: [
        "A": 0,
        "B": 3,
      ],
      reducer: firstReducer,
      environment: First() // Swift ≥ 5.4 can use .init()
        .with(\.int, 2)
    )

    store.send(.action) {
      $0 = [
        "A": 2,
        "B": 2,
      ]
    }
  }
  
  func testComposableAutoComposableComposableBridging() {
    class Third: ComposableEnvironment {
      @Dependency(\.int) var integer
    }
    class Second: ComposableEnvironment {
      @DerivedEnvironment<Third> var third
    }
    class First: ComposableEnvironment {}
    
    enum Action {
      case action
    }

    let thirdReducer = Reducer<Int, Action, Third> {
      state, _, environment in
      state = environment.integer
      return .none
    }

    let secondReducer = Reducer<Int, Action, Second>.combine(
      thirdReducer.pullback(state: \.self, action: /.self, environment: \.third)
    )

    let firstReducer = Reducer<Int, Action, First>.combine(
      secondReducer.pullback(state: \.self, action: /.self)
    )

    let store = TestStore(
      initialState: 0,
      reducer: firstReducer,
      environment: First() // Swift 5.4+ can use .init()
        .with(\.int, 2)
    )

    store.send(.action) { $0 = 2 }
  }
  
  func testAutoComposableComposableAutoComposableBridging() {
    class Third: ComposableEnvironment { }
    class Second: ComposableEnvironment { }
    class First: ComposableEnvironment {
      @DerivedEnvironment<Second> var second
    }
    
    enum Action {
      case action
    }

    let thirdReducer = Reducer<Int, Action, Third> {
      state, _, environment in
      state = environment.int
      return .none
    }

    let secondReducer = Reducer<Int, Action, Second>.combine(
      thirdReducer.pullback(state: \.self, action: /.self)
    )

    let firstReducer = Reducer<Int, Action, First>.combine(
      secondReducer.pullback(state: \.self, action: /.self, environment: \.second)
    )

    let store = TestStore(
      initialState: 0,
      reducer: firstReducer,
      environment: First() // Swift ≥ 5.4 can use .init()
        .with(\.int, 2)
    )
    
    store.send(.action) { $0 = 2 }
  }
}
