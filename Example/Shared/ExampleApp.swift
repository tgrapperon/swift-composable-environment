import ComposableArchitecture
import ComposableEnvironment
import SwiftUI

let store = Store(
  initialState: Level0State(level1: .init(
    first: .init(randomNumber: nil),
    second: .init(randomNumber: nil)
  )),
  reducer: level0Reducer,
  environment: Level0Environment()
)

@main
struct ExampleApp: App {
  var body: some Scene {
    WindowGroup {
      Level0View(store)
    }
  }
}
