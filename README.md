# ComposableEnvironment

This library brings an API similar to SwiftUI's `Environment` to derive and compose `Environment`'s in [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture). 

## Example
Each dependency we want to share using `ComposableEnvironment` should be declared with a `DependencyKey`'s in a similar fashion one declares custom `EnvironmentValue`'s in SwiftUI using `EnvironmentKey`'s. Let define a `mainQueue` dependency:
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
We only have to declare `ChildEnvironment` as a property of `RootEnvironment`, with the `@DerivedEnvironment` property wrapper. Like with SwiftUI's `View`, if one modifies a dependency with `with(keypath, value)`, only the environment's instance and its derived environments will receive the new dependency. Its eventual parent and siblings will be unaffected.

## Advantages over manual management
- You don't have to instantiate your child environments, nor to manage their initializers.
- You don't have to host a dependency in some environment for the sole purpose of passing it to child environments. You can define a dependency in the `Root` environment and retrieve it in any descendant (if none of its ancester has overidden the root's value in the meantime). You don't have to declare this dependency in the `Environment`'s which are not using it explicitly.
- Your dependencies are clearly tagged. It's more difficult to mix up dependencies with the same interface.
- `ComposableEnvironment`'s instances are cached, and you can access them direcly by their `KeyPath` in their parent when pulling-back your reducers.
- You can quickly override the dependencies of any environment with a chaining API. You can easily create specific configurations for your tests or `SwiftUI` previews.
- You write much less code, and you get more autocompletion.
- You can fall back to manual management with `ComposableEnvironment` if necessary, and store properties that are not `@Dependency`'s.

## Inconvenients over manual management
- Your environments need to be subclasses of `ComposableEnvironment`.
- Your environments must be connected through `@DerivedEnvironment`. If one of the members of the environment tree is not a `ComposableEnvironment`, nor derived from another via `@DerivedEnvironment`, automatic syncing of dependencies will stop to work downstream, as the next `ComposableEnvironment` will act as a root for its subtree (I guess some safeguards are possible).
- You need to declare your dependencies explicitly in the `ComposedDependencies` pseudo-namespace. It may require to plan ahead if you're working with an highly modularized application. I guess it should be possible to define equivalence relations between dependencies at some point. Otherwise, I would recommend to define transversal dependencies like `mainQueue` or `Date`, in a separate module that can be shared by each feature.
- With the current implementation, dependencies in a `ComposableEnvironment` can't be updated once any of its `DerivedEnvironment` has been accessed.
