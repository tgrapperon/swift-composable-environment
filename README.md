# ComposableEnvironment
[![](https://github.com/tgrapperon/swift-composable-environment/actions/workflows/swift.yml/badge.svg)](https://github.com/tgrapperon/swift-composable-environment/actions/workflows/swift.yml)
[![Documentation](https://github.com/tgrapperon/swift-composable-environment/actions/workflows/documentation.yml/badge.svg)](https://github.com/tgrapperon/swift-composable-environment/wiki/ComposableEnvironment-Documentation)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ftgrapperon%2Fswift-composable-environment%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/tgrapperon/swift-composable-environment)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Ftgrapperon%2Fswift-composable-environment%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/tgrapperon/swift-composable-environment)

This library brings an API similar to SwiftUI's `Environment` to derive and compose `Environment`'s in [The Composable Architecture](https://github.com/pointfreeco/swift-composable-architecture) (TCA). 

By `Environment`, one understands a type that vends *dependencies*. This library eases this process by standardizing these dependencies, and the way they are passed from one environment type to another when composing domains using TCA. Like in SwiftUI, this library allows passing values (in this case dependencies) down a tree of values (in this case the reducers) without having to specify them at each step. You don't need to provide initial values for dependencies in your `Environment`'s, you don't need to inject dependencies from a parent environment to a child environment, and in many cases, you don't even need to instantiate the child environment.

This library comes with two mutually exclusive modules, `ComposableEnvironment` and `GlobalEnvironment`, which are providing different functionalities for different tradeoffs.
`ComposableEnvironment` allows defining environments where dependencies can be overridden at any point in the reducer chain. Like in SwiftUI, setting a value for a dependency propagates downstream until it is eventually overridden again.
`GlobalEnvironment` allows defining global dependencies that are the same for all reducers in the chain. This is the most frequent configuration.
Both modules are defined in the same repository to maintain source compatibility between them.

**The `GlobalEnvironment` module should fit most of the cases.**

## Defining dependencies
Each dependency we want to share should be declared via subscript with a `KeyPath` for the dependency. Let define a `mainQueue` dependency:
```swift
extension Dependencies {
  var mainQueue: AnySchedulerOf<DispatchQueue> {
    get { self[\.mainQueue] ?? .main }
    set { self[\.mainQueue] = newValue }
  }
}
```
## Using dependencies
Whereas you're using `ComposableEnvironment` or `GlobalEnvironment`, there are distinct ways to access your dependencies.

### `@Dependency` property wrapper
You use the `@Dependency` property wrapper to expose a dependency to your environment. This property wrapper takes as argument the `KeyPath` of the property you defined in `Dependencies`. For example, to expose the `mainQueue` defined above, you declare
```swift
@Dependency(\.mainQueue) var main
```
Note that you don't need to provide a value for the dependency. The effective value for this property is the current value from the environment, or the `default` value if you defined none.

### Implicit subscript
You can also already use a subscript from your `Environment` to directly access the dependency without having to expose it. You use this subscript with the `KeyPath` from the property defined in `Dependencies`. For example:
```swift
environment[\.mainQueue]
```
returns the same value as `@Dependency(\.mainQueue)`.

Whereas you use one or another is up to you. The implicit subscript is faster, but some prefer having explicit declarations to assess the environment's dependencies.

### Direct access (`ComposableEnvironment` only)
When using `ComposableEnvironment`, you can directly access a dependency by using its computed property name in `Dependencies` from any `ComposableEnvironment` subclass, even if you did not expose the dependency using the `@Dependency` property wrapper:
```swift
environment.mainQueue
```
This direct access is unfortunately not possible when using `GlobalEnvironment`.

## Environments

The way you define environments differs, whereas you're using `ComposableEnvironment` or `GlobalEnvironment`.

### Defining Environments while using `ComposableEnvironment`
When using `ComposableEnvironment`, all your environments need to be subclasses of `ComposableEnvironment`. This is unfortunately required to automatically handle the storage of the private environment values state at a given node. Let define the `ParentEnvironment` exposing the `mainQueue` dependency:
```swift
public class ParentEnvironment: ComposableEnvironment {
  @Dependency(\.mainQueue) var main
}
```
Imagine that you need to embed a `Child` TCA feature into the `Parent` feature. You declare the embedding using the `@DerivedEnvironment` property wrapper:
```swift
public class ParentEnvironment: ComposableEnvironment {
  @Dependency(\.mainQueue) var main
  @DerivedEnvironment<ChildEnvironment> var child
}
```
When you access the `child` property of `ParentEnvironment`, it automatically inherit the dependencies from `ParentEnvironment`. You can pullback `childReducer` using the standard methods:
```swift
childReducer.pullback(state: \.child, action: /ParentAction.child, environment: \.child)
```
You can assign a value to the child environment inline with its declaration, or let the library handle the initialization of an instance for you.
In this last case, you can even embed the child reducer using environment-less pullbacks: 
```swift
childReducer.pullback(state: \.child, action: /ParentAction.child)
```
Note: If you use an environment-less pullback, any initial value you may have defined inline will be discarded. In this case, you should use standard pullbacks with the `\.child` `KeyPath` as a function `(ParentEnvironment) -> ChildEnvironment`.

### Defining Environments while using `GlobalEnvironment`
When using `GlobalEnvironment`, your environment, whereas it's a value or a reference type, should conform to the `GlobalEnvironment` protocol.
You can then define and use your dependencies in the same way as for `ComposableEnvironment`. As all dependencies are globally shared and there are no specific dependencies to inherit, it makes less sense to use the `@DerivedEnvironment` property wrapper if you're not using it to define dependency aliases (see below).
```swift
public struct ParentEnvironment: GlobalEnvironment {
  public init() {}
  @Dependency(\.mainQueue) var main
}
```
You still have access to environment-less pullbacks, with the same API:
```swift
childReducer.pullback(state: \.child, action: /ParentAction.child)
```
The only requirement for `GlobalEnvironment` is to provide an `init()` initializer. If this is not possible for your child environment, you can still implement the `GlobalDependenciesAccessing` marker protocol which has no requirements but gives your type access to global dependencies using the implicit subscript accessors. You can also do nothing and use the `@Dependency` which has no restriction over its host like the `ComposableEnvironment` version has (it needs to be installed in a `ComposableEnvironment` subclass).
If you can't conform to `GlobalEnvironment`, you only lose access to the environment-less pullbacks.

## Assigning values to dependencies
Once dependencies are defined as computed properties of the `Dependencies`, you only access them through your environment, whereas it's a `ComposableEnvironment` subclass or some type conforming to `GlobalDependenciesAccessing`.

To set a value to a dependency, you use the `with(keyPath,value)` chainable method from your environment:
```
environment
  .with(\.mainQueue, DispatchQueue.main)
  .with(\.uuidGenerator, { UUID() })
  …
```
When you're using `GlobalEnvironment`, each dependency is set globally. If you set the same dependency twice, the last call prevails.
When you're using `ComposableEnvironment`, each dependency is set along the dependency tree until it eventually is set again using a `with(keyPath, anotherValue)` call on a child environment. This works in the same fashion as SwiftUI `Environment`.

## Aliasing dependencies
In the case the same dependency was defined by different domains using different computed properties in `Dependencies`, you can alias them using the `aliasing(dependencyKeyPath, to: referenceDependencyKeyPath)` chainable method from your environment. For example, if you defined the main queue as `.main` in some feature, and as `mainQueue` in another, you can alias both using
```swift
environment.aliasing(\.main, to: \.mainQueue)
```
Once aliased, you can assign a value using either `KeyPath`. If no value is set for the dependency, the second argument provides its default for both `KeyPaths`.

You can also alias dependencies "on the spot", using the `@DerivedEnvironment` property wrapper. Its initializer provides a closure transforming a provided `AliasBuilder`.
This type has only one chainable method, `alias(dependencyKeyPath, to: referenceDependencyKeyPath)`. For example, if the `main` dependency is defined in the `child` derived environment, you can define an alias to the `mainQueue` dependency from `ParentEnvironment` using:
```swift
public class ParentEnvironment: ComposableEnvironment {
  @Dependency(\.mainQueue) var mainQueue
  @DerivedEnvironment<ChildEnvironment>(aliases: {
    $0.alias(\.main, to: \.mainQueue)
  }) var child
}
```
When using this property wrapper, you don't need to define the alias from the environment using `.aliasing()`.

Dependencies aliases are always global.

## Environment-less pullbacks

### Omitting the `@DerivedEnvironment` property wrapper
You can forgo `@DerivedEnvironment` declarations when:
- You don't need to customize dependencies specifically for the child environment when using `ComposableEnvironment`.
- You don't need to alias dependencies "on the spot", using the `@DerivedEnvironment` property wrapper, when using either module.
The example app shows how this feature can be used and mixed with the property-wrapper approach when using `ComposableEnvironment`.

### Using environment-less pullbacks
When your environment can be instantiated automatically, you can use environment-less pullbacks:
```swift
childReducer.pullback(state: \.child, action: /ParentAction.child)
// or, for collections of features:
childReducer.forEach(state: \.children, action: /ParentAction.children)
```
Please note that in order to access such pullbacks when using  `GlobalEnvironment`, your environment needs to conform to the `GlobalEnvironment` protocol.

## Choosing between `ComposableEnvironment` and `GlobalEnvironment`
As a rule of thumb, if you need to modify your dependencies in the middle of the environment's tree, you should use `ComposableEnvironment`. If all dependencies are shared across your environments, you should use `GlobalEnvironment`. As the first configuration is quite rare, we recommend using `GlobalEnvironment` if you're in doubt, as it is the simplest to implement in an existing TCA project.

The principal differences between the two approaches are summarized in the following table:
|  | `ComposableEnvironment` | `GlobalEnvironment` |
|---|---|---|
| Environment Type | Classes | Any existential <br>(struct, classes, etc.) |
| Environment Tree | All nodes should be <br>`ComposableEnvironment` subclasses | Free, <br>can opt-in/opt-out at any point |
| Dependency values | Customizable per instance | Globally defined |
| Access to dependencies | `@Dependency`, direct, implicit | `@Dependency`, implicit |

## Correspondence with SwiftUI's Environment
In order to ease its learning curve, the library bases its API on SwiftUI's Environment. We have the following functional correspondences:
| SwiftUI | ComposableEnvironment| Usage |
|---|---|---|
|`EnvironmentKey`|`DependencyKey`| Identify a shared value, deprecated |
|`EnvironmentValues`|`Dependencies`| Expose a shared value |
|`@Environment`|`@Dependency`| Retrieve a shared value |
|`View`|`(Composable/Global)Environment`| A node |
|`View.body`| `@DerivedEnvironment`'s | A list of children of the node |
|`View`<br>&nbsp;&nbsp;&nbsp;`.environment(keyPath:value:)`|`(Composable/Global)Environment`<br>&nbsp;&nbsp;&nbsp;`.with(keyPath:value:)`| Set a shared value for a node and its children |

## Documentation
The latest documentation for ComposableEnvironment's APIs is available [here](https://github.com/tgrapperon/swift-composable-environment/wiki/ComposableEnvironment-Documentation).

## Installation
Add 
```swift
.package(url: "https://github.com/tgrapperon/swift-composable-environment", from: "0.5.0")
```
to your Package dependencies in `Package.swift`, and then
```swift
.product(name: "ComposableEnvironment", package: "swift-composable-environment")
// or
.product(name: "GlobalEnvironment", package: "swift-composable-environment")
```
to your target's dependencies, depending on the module you want to use.
