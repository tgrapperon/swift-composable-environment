import Combine
import ComposableArchitecture
import ComposableEnvironment
import SwiftUI

// Define some domain-specific dependency
public typealias RandomNumberGenerator = () -> Int

// Create a Composable Dependency:
private struct RNGKey: DependencyKey {
  static var defaultValue: RandomNumberGenerator {
    { Int.random(in: 0 ... 1000) }
  }
}

// Install it in `Dependencies`:
public extension Dependencies {
  var rng: RandomNumberGenerator {
    get { self[RNGKey.self] }
    set { self[RNGKey.self] = newValue }
  }
}

// "Level2" Feature

struct Level2State: Equatable {
  var randomNumber: Int?
}

enum Level2Action {
  case randomNumber(Int)
  case requestRandomNumber
}

class Level2Environment: ComposableEnvironment {
  @Dependency(\.rng) var randomNumberGenerator

  func randomNumber() -> Future<Int, Never> {
    .init { [randomNumberGenerator] in
      let number = randomNumberGenerator()
      $0(.success(number))
    }
  }
}

let level2Reducer = Reducer<Level2State, Level2Action, Level2Environment> {
  state, action, environment in
  switch action {
  case let .randomNumber(number):
    state.randomNumber = number
    return .none
  case .requestRandomNumber:
    // Note that we don't have defined any `@Dependency(\.mainQueue)` in environment.
    // We use its global property name instead:
    return environment
      .randomNumber()
      .map(Level2Action.randomNumber)
      .receive(on: environment.mainQueue)
      .eraseToEffect()
  }
}

struct Level2View: View {
  let store: Store<Level2State, Level2Action>
  init(store: Store<Level2State, Level2Action>) {
    self.store = store
  }

  var body: some View {
    WithViewStore(store) { viewStore in
      VStack {
        if let number = viewStore.randomNumber {
          Text("Your random number is \(number)!")
            .font(.headline)
        } else {
          Text("No number yet…")
            .foregroundColor(.secondary)
        }
        Button(action: { viewStore.send(.requestRandomNumber) }) {
          Text("Request some random number")
        }
      }
    }
  }
}

struct Level2View_Preview: PreviewProvider {
  static var previews: some View {
    Level2View(store:
      .init(initialState:
        .init(
          randomNumber: 5
        ),
        reducer: level2Reducer,
        environment:
        Level2Environment() // Swift ≥ 5.4 can use .init()
          .with(\.mainQueue, .immediate)
          .with(\.rng) { 12 })
    )
    Level2View(store:
      .init(initialState:
        .init(
          randomNumber: nil
        ),
        reducer: level2Reducer,
        environment:
        Level2Environment() // Swift ≥ 5.4 can use .init()
          .with(\.mainQueue, .immediate)
          .with(\.rng) { 54 })
    )
  }
}
