# ComposableEnvironment
[![](https://github.com/tgrapperon/swift-composable-environment/actions/workflows/swift.yml/badge.svg)](https://github.com/tgrapperon/swift-composable-environment/actions/workflows/swift.yml)
[![Documentation](https://github.com/tgrapperon/swift-composable-environment/actions/workflows/documentation.yml/badge.svg)](https://github.com/tgrapperon/swift-composable-environment/wiki/ComposableEnvironment-Documentation)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ftgrapperon%2Fswift-composable-environment%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/tgrapperon/swift-composable-environment)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ftgrapperon%2Fswift-composable-environment%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/tgrapperon/swift-composable-environment)

This library brings an API similar to SwiftUI's `Environment` to derive and compose `Environment`'s in [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture). 

## Example

Each dependency we want to share using `ComposableEnvironment` should be declared with a `DependencyKey`'s in a similar fashion one declares custom `EnvironmentValue`'s in SwiftUI using `EnvironmentKey`'s. Let define a `eventHandlingScheduler` dependency and register it in the `ComposableDependencies`:

````swift
extension DependencyKeys {
  // We keep this naming for the case if you want to use some background scheduler
  // for your store events for some reason
  public struct EventHandlingScheduler DependencyKey {
    public static var defaultValue: AnySchedulerOf<DispatchQueue> { .main }
  }
}

extension ComposableDependencies {
  public var eventHandlingScheduler: NoOptionsSchedulerOf<DispatchQueue> {
    get { self[DependencyKeys.EventHandlingScheduler.self] }
    set { self[DependencyKeys.EventHandlingScheduler.self] = newValue }
  }
}
````

Also, you may want to access global schedulers for some backgound work, lets define a client

````swift
public struct GlobalSchedulersClient {
  public init(
    _ scheduler: @escaping (DispatchQoS.QoSClass) -> AnySchedulerOf<DispatchQueue>
  ) {
    self.scheduler = scheduler
  }

  public var scheduler: (DispatchQoS.QoSClass) -> AnySchedulerOf<DispatchQueue>

  public func callAsFunction(qos: DispatchQoS.QoSClass = .default) -> AnySchedulerOf<DispatchQueue> {
    return scheduler(qos)
  }
}

extension GlobalSchedulersClient {
  public static let live: GlobalSchedulersClient = .init { qos in
    return DispatchQueue.global(qos: qos).eraseToAnyScheduler()
  }
}
````

And do the same for  `GlobalScheduler` dependency

````swift
extension DependencyKeys {
  public enum GlobalScheduler: DependencyKey {
    public static var defaultValue: GlobalSchedulersClient { .live }
  }
}

extension ComposableDependencies {
  public var globalSchedulers: GlobalSchedulersClient {
    get { self[DependencyKeys.GlobalScheduler.self] }
    set { self[DependencyKeys.GlobalScheduler.self] = newValue }
  }
}
````

Now, lets define `StoreSchedulers` environment:

````swift
public class StoreSchedulers: ComposableEnvironment {
  @Dependency(\.eventHandlingScheduler)
  public var main
  
  @Dependency(\.backgroundSchedulers)
  public var background
}
````

And our `RootEnvironment`:

````swift
class RootEnvironment: ComposableEnvironment {
  @DerivedEnvironment<StoreSchedulers>
  var schedulers
}
````

Then we can use our environment:

````swift
let environment = RootEnvironment()
environment.schedulers
  .global(qos: .background)
  .schedule { print("Scheduled background task") }
````

Please note that we didn't have to set an initial value to `mainQueue`. `@Dependency` are immutable, but we can easily attribute new values with a chaining API:

````swift
let failingEventHandling = RootEnvironment().with(\.eventHandingScheduler, .failing)
````

An now, the prestige! Let `ChildEnvironment` be

````swift
class ChildEnvironment: ComposableEnvironment {
  @Dependency(\.eventHandlingScheduler) var mainQueue
}
````
If `RootEnvironment` is modified like

````swift
class RootEnvironment: ComposableEnvironment {
  @Dependency(\.eventHandlingScheduler) var mainQueue
  @DerivedEnvironment<ChildEnvironment> var child
}
````

`child.mainQueue` will be synchronized with `RootEnvironment`'s value. In other words,
````swift
Root().with(\.mainQueue, .failing).child.mainQueue == .failing
````

We only have to declare `ChildEnvironment` as a property of `RootEnvironment`, with the `@DerivedEnvironment` property wrapper. Like with SwiftUI's `View`, if one modifies a dependency with `with(keypath, value)`, only the environment's instance and its derived environments will receive the new dependency. Its eventual parent and siblings will be unaffected.

### AutoComposableEnvironment

Since [`v0.4`](https://github.com/tgrapperon/swift-composable-environment/releases/tag/0.4.0), you can optionally forgo `@Dependency` and `@DerivedEnvironment` declarations:

- You can directly access dependencies using their property name defined in `ComposableDepencies` directly in your `ComposableEnvironment` subclass, as if you defined `@Dependency(\.someDependency) var someDependency`.

- You can use environment-less pullbacks. They will vend your derived feature's reducer a derived environment of the expected type. This is equivalent to defining  `@DerivedEnvironment<ChildEnvironment> var child` in your parent's environment, and using `[…], environment:\.child)` when pulling-back.

You still need `@Dependency` if you want to customize the exposed name of your dependency in your environment, like

```swift
@Dependency(\.someDependency) var anotherNameForTheDependency
```

You still need `@DerivedEnvironment` if you want to override the dependencies inside the environment's chain:

```swift
@DerivedEnvironment var child = ChildEnvironment().with(\.someDependency, someValue)
```

The example app shows how this feature can be used and mixed with the property-wrapper approach.

## Correspondance with SwiftUI's Environment

In order to ease its learning curve, the library bases its API on SwiftUI's Environment. We have the following functional correspondances:
| SwiftUI | ComposableEnvironment| Usage |
|---|---|---|
|`EnvironmentKey`|`DependencyKey`| Identify a shared value |
|`EnvironmentValues`|`ComposableDependencies`| Expose a shared value |
|`@Environment`|`@Dependency`| Retrieve a shared value |
|`View`|`ComposableEnvironment`| A node |
|`View.body`| `@DerivedEnvironment`'s | A list of children of the node |
|`View.environment(keyPath:value:)`|`ComposableEnvironment.with(keyPath:value:)`| Set a shared value for a node and its children |

## Documentation

The latest documentation for ComposableEnvironment's APIs is available [here](https://github.com/tgrapperon/swift-composable-environment/wiki/ComposableEnvironment-Documentation).

## Advantages over manual management

- You don't have to instantiate your child environments, nor to manage their initializers.
- You don't have to host a dependency in some environment for the sole purpose of passing it to child environments. You can define a dependency in the `Root` environment and retrieve it in any descendant (if none of its ancester has overidden the root's value in the meantime). You don't have to declare this dependency in the `Environment`'s which are not using it explicitly.
- Your dependencies are clearly tagged. It's more difficult to mix up dependencies with the same interface.
- `ComposableEnvironment`'s instances are cached, and you can access them direcly by their `KeyPath` in their parent when pulling-back your reducers.
- You can quickly override the dependencies of any environment with a chaining API. You can easily create specific configurations for your tests or `SwiftUI` previews.
- You write much less code, and you get more autocompletion.
- You can fall back to manual management with `ComposableEnvironment` if necessary, and store properties that are not `@Dependency`'s.

## Inconvenients compared to manual management

- Your environments need to be subclasses of `ComposableEnvironment`.
- Your environments must be connected through `@DerivedEnvironment`. If one of the members of the environment tree is not a `ComposableEnvironment`, nor derived from another via `@DerivedEnvironment`, automatic syncing of dependencies will stop to work downstream, as the next `ComposableEnvironment` will act as a root for its subtree (I guess some safeguards are possible).
- You need to declare your dependencies explicitly in the `ComposedDependencies` pseudo-namespace. It may require to plan ahead if you're working with an highly modularized application. I guess it should be possible to define equivalence relations between dependencies at some point. Otherwise, I would recommend to define transversal dependencies like `mainQueue` or `Date`, in a separate module that can be shared by each feature.

## Installation

Add 

```swift
.package(url: "https://github.com/tgrapperon/swift-composable-environment", from: "0.0.4")
```

to your Package dependencies in `Package.swift`, and then

```swift
.product(name: "ComposableEnvironment", package: "swift-composable-environment")
```

to your target's dependencies.
