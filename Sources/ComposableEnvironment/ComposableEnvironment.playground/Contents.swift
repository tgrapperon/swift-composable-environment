import ComposableEnvironment
import Foundation

struct MainQueueKey: DependencyKey {
  static var defaultValue: DispatchQueue { .main }
}

struct UUIDGenerator: DependencyKey {
  static var defaultValue: () -> UUID { { UUID() } }
}

struct IntKey: DependencyKey {
  static var defaultValue: Int { 1 }
}

extension ComposableDependencies {
  var mainQueue: DispatchQueue {
    get { self[MainQueueKey.self] }
    set { self[MainQueueKey.self] = newValue }
  }

  var uuidGenerator: () -> UUID {
    get { self[UUIDGenerator.self] }
    set { self[UUIDGenerator.self] = newValue }
  }

  var int: Int {
    get { self[IntKey.self] }
    set { self[IntKey.self] = newValue }
  }
}

class Parent: ComposableEnvironment {
  @DerivedEnvironment<Child1> var child1
}

class Child1: ComposableEnvironment {
  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.int) var int

  @DerivedEnvironment<Child2> var child21
  @DerivedEnvironment var child22 = Child2()
}

class Child2: ComposableEnvironment {
  @Dependency(\.mainQueue) var mainQueue
  @Dependency(\.uuidGenerator) var uuidGenerator
  @Dependency(\.int) var int
}

let parent = Parent()

parent.child1.int
parent.child1.child21.int
parent.child1.child22.int

parent.child1.with(\.int, 4)

parent.child1.int
parent.child1.child21.int
parent.child1.child22.int
