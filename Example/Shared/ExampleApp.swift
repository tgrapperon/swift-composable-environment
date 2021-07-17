import ComposableArchitecture
import ComposableEnvironment
import SwiftUI

let store = Store<Level0State, Level0Action>(
  initialState:
  .init(level1: .init(
    first: .init(randomNumber: nil),
    second: .init(randomNumber: nil)
  )),
  reducer: level0Reducer,
  environment: .init()
)

@main
struct ExampleApp: App {
  var body: some Scene {
    WindowGroup {
      Level0View(store: store)
    }
  }
}
