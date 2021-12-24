import Combine
import ComposableArchitecture
import ComposableEnvironment
import SwiftUI

// "Level0" Feature, which embeds a `Level1` feature

struct Level0State: Equatable {
  var level1: Level1State
  var isReady: Bool = false
}

enum Level0Action {
  case isReady
  case level1(Level1Action)
  case onAppear
}

class Level0Environment: ComposableEnvironment {
  // This style of using property-wrappers allows to
  // find derived environment type a bit easier, then DerivedEnvironment<Type>
  // and visual composition is a bit better, so we keep wrapper as a simple annotation
  // and all of the information that is related to a property is on one line
  @DerivedEnvironment
  var schedulers: StoreSchedulers
  
  @DerivedEnvironment
  var level1: Level1Environment
}

// You may prefer to define type explicitly to avoid using `get` helper
//
// let level0Reducer = Reducer<
//   Level0State,
//   Level0Action,
//   Level0Environment
// >.combine(
//   level1Reducer.pullback(
//     state: \.level1,
//     action: /Level0Action.level1,
//     environment: \.level1
//   ),
//   ...
// )

let level0Reducer = Reducer.combine(
  level1Reducer.pullback(
    state: \Level0State.level1,
    action: /Level0Action.level1,
    environment: get(\Level0Environment.level1)
  ),
  Reducer { state, action, environment in
    switch action {
    case .isReady:
      state.isReady = true
      return .none
      
    case .level1:
      return .none
      
    case .onAppear:
      return Effect(value: .isReady)
        .delay(for: 1, scheduler: environment.schedulers.background()) // Simulate something lengthy…
        .receive(on: environment.schedulers.main)
        .eraseToEffect()
    }
  }
)

// Alternatively, we can directly tap into the environment's dependepencies using
// their global property name, meaning that we can even bypass declarations like
// `@Dependency(\.mainQueue) var main` in the environment to write:
//
//   return Effect(value: .isReady)
//     .delay(for: 1, scheduler: environment.globalSchedulers(qos: .default))
//     .receive(on: environment.mainQueue)
//     .eraseToEffect()

struct Level0View: View {
  let store: Store<Level0State, Level0Action>
  
  init(_ store: Store<Level0State, Level0Action>) {
    self.store = store
  }
  
  var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        Text("Random numbers")
          .font(.title)
        Level1View(store.scope(
          state: \.level1,
          action: Level0Action.level1
        ))
        .padding()
        .disabled(!viewStore.isReady)
      }
      .onAppear { viewStore.send(.onAppear) }
      .fixedSize()
    }
  }
}

struct Level0View_Preview: PreviewProvider {
  static var previews: some View {
    Level0View(Store(
      initialState: .init(
        level1: .init(
          first: .init(randomNumber: 6),
          second: .init(randomNumber: nil)
        )
      ),
      reducer: level0Reducer,
      environment: Level0Environment() // Swift ≥ 5.4 can use .init()
        .with(\.eventHandlingScheduler, AnyScheduler.immediate.ignoreOptions())
        .with(\.globalSchedulers, .init { _ in AnyScheduler.immediate.ignoreOptions() })
        // We can set the value of `rng` even if Level0Environment doesn't have a `rng` property:
        .with(\.rng) { 4 }
    ))
    Level0View(Store(
      initialState:.init(level1: .init(
        first: .init(randomNumber: nil),
        second: .init(randomNumber: nil)
      )),
      reducer: level0Reducer,
      // An environment default dependencies:
      environment: .init()
    ))
  }
}
