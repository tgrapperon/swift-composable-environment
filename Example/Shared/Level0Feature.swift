import Combine
import ComposableArchitecture
import ComposableEnvironment
import SwiftUI

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
  // Dependencies
  @Dependency(\.mainQueue) var main
  @Dependency(\.backgroundQueue) var background

  // Derived Environments
  @DerivedEnvironment<Level1Environment> var level1
}

let level0Reducer = Reducer<Level0State, Level0Action, Level0Environment>.combine(
  level1Reducer.pullback(state: \.level1,
                         action: /Level0Action.level1,
                         environment: \.level1),
  Reducer<Level0State, Level0Action, Level0Environment> {
    state, action, environment in
    switch action {
    case .isReady:
      state.isReady = true
      return .none
    case .level1:
      return .none
    case .onAppear:
      return Effect(value: .isReady)
        .delay(for: 1, scheduler: environment.background) // Simulate something lengthy…
        .receive(on: environment.main)
        .eraseToEffect()
      
      // Alternatively, we can directly tap into the environment's dependepencies using
      // their global KeyPath, meaning that we can even bypass declarations like
      // `@Dependency(\.mainQueue) var main` in the environment.
      //
      //   return Effect(value: .isReady)
      //     .delay(for: 1, scheduler: environment[\.backgroundQueue])
      //     .receive(on: environment[\.mainQueue])
      //     .eraseToEffect()
    }
  }
)

struct Level0View: View {
  let store: Store<Level0State, Level0Action>
  init(store: Store<Level0State, Level0Action>) {
    self.store = store
  }

  var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        Text("Random numbers")
          .font(.title)
        Level1View(store: store.scope(state: \.level1, action: Level0Action.level1))
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
    Level0View(store:
      .init(initialState:
        .init(
          level1: .init(
            first: .init(randomNumber: 6),
            second: .init(randomNumber: nil)
          )
        ),
        reducer: level0Reducer,
        environment: .init()
          .with(\.mainQueue, .immediate)
          .with(\.backgroundQueue, .immediate)
          // We can set the value of `rng` even if Level0Environment doesn't have a `rng` property:
          .with(\.rng) { 4 })
    )
    Level0View(store:
      .init(initialState:
        .init(level1: .init(
          first: .init(randomNumber: nil),
          second: .init(randomNumber: nil)
        )),
        reducer: level0Reducer,
        environment: .init())
    )
  }
}


