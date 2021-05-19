# ComposableEnvironment

This library brings an API similar to SwiftUI's `Environment` to derive and compose `Environment`'s in [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture). 

## Example
Each dependency we want to share using `ComposableEnvironment` should be declared with a `DependencyKey`'s in a similar fashion one declare custom `EnvironmentValue`'s in SwiftUI using `EnvironmentKey`'s. Let define a `mainQueue` dependency:
````swift
struct MainQueueKey: DependencyKey {
  static var defaultValue: AnySchedulerOf<DispatchQueue> { .main }
}
````
We also install it in `ComposableDependencies`:
````swift
extension ComposableDependencies {
  var mainQueue: AnySchedulerOf<DispatchQueue> {
    get { self[MainQueueKey.self] }
    set { self[MainQueueKey.self] = newValue }
  }
}
````
Now, let define `RootEnvironment`:
````swift
class RootEnvironment: ComposableEnvironment {
  @Dependency(\.mainQueue) var mainQueue
}
````
Please note that we didn't have to set an initial value to `mainQueue`. `@Dependency` are immutable, but we can easily attribute new values with a chaining API:
````swift
let failingMain = Root().with(\.mainQueue, .failing)
````

An now, the prestige! Let `ChildEnvironment` be 
````swift
class ChildEnvironment: ComposableEnvironment {
  @Dependency(\.mainQueue) var mainQueue
}
````
If `RootEnvironment` is modified like
````swift
class RootEnvironment: ComposableEnvironment {
  @Dependency(\.mainQueue) var mainQueue
  @DerivedEnvironment<ChildEnvironment> var child
}
````
`child.mainQueue` will be synchronized with `RootEnvironment`'s value. In other words,
````swift
Root().with(\.mainQueue, .failing).child.mainQueue == .failing
````
We only have to declare `ChildEnvironment` as a property of `RootEnvironment`. Like with SwiftUI's `View`, if one modify a dependency with `with(keypath, value)`, only the environment's instance and its derived environments will receive the new dependency. Its eventual parent and siblings will be unaffected.
