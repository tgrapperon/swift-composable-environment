@testable import ComposableEnvironment
import XCTest

struct IntKey: DependencyKey {
  static var defaultValue: Int { 1 }
}

extension ComposableDependencies {
  var int: Int {
    get { self[IntKey.self] }
    set { self[IntKey.self] = newValue }
  }
}

final class ComposableEnvironmentTests: XCTestCase {
  func testDependency() {
    class Env: ComposableEnvironment {
      @Dependency(\.int) var int
    }
    let env = Env()
    XCTAssertEqual(env.int, 1)
  }
  
  func testDependencyPropagation() {
    class Parent: ComposableEnvironment {
      @Dependency(\.int) var int
      @DerivedEnvironment<Child> var child
    }
    class Child: ComposableEnvironment {
      @Dependency(\.int) var int
    }
    let parent = Parent()
    XCTAssertEqual(parent.child.int, 1)
    
    let parentWith2 = Parent().with(\.int, 2)
    XCTAssertEqual(parentWith2.int, 2)
    XCTAssertEqual(parentWith2.child.int, 2)
  }
  
  func testDependencyOverride() {
    class Parent: ComposableEnvironment {
      @Dependency(\.int) var int
      @DerivedEnvironment<Child> var child
      @DerivedEnvironment var sibling = Child().with(\.int, 3)
    }
    class Child: ComposableEnvironment {
      @Dependency(\.int) var int
    }
    
    let parent = Parent().with(\.int, 2)
    XCTAssertEqual(parent.int, 2)
    XCTAssertEqual(parent.child.int, 2)
    XCTAssertEqual(parent.sibling.int, 3)
  }
  
  func testDerivedWithProperties() {
    class Parent: ComposableEnvironment {
      @Dependency(\.int) var int
      @DerivedEnvironment<Child> var child
      @DerivedEnvironment var sibling = Child(otherInt: 5).with(\.int, 3)
    }
    final class Child: ComposableEnvironment {
      @Dependency(\.int) var int
      var otherInt: Int = 4
      required init() {}
      init(otherInt: Int) {
        self.otherInt = otherInt
      }
    }
    
    let parent = Parent().with(\.int, 2)
    XCTAssertEqual(parent.int, 2)
    XCTAssertEqual(parent.child.int, 2)
    XCTAssertEqual(parent.sibling.int, 3)
    
    XCTAssertEqual(parent.child.otherInt, 4)
    XCTAssertEqual(parent.sibling.otherInt, 5)
  }
  
  func testLongChainsPropagation() {
    class Parent: ComposableEnvironment {
      @Dependency(\.int) var int
      @DerivedEnvironment<C1> var c1
    }
    final class C1: ComposableEnvironment {
      @DerivedEnvironment<C2> var c2
    }
    final class C2: ComposableEnvironment {
      @DerivedEnvironment<C3> var c3
    }
    final class C3: ComposableEnvironment {
      @DerivedEnvironment<C4> var c4
      @Dependency(\.int) var int
    }
    final class C4: ComposableEnvironment {
      @DerivedEnvironment<C5> var c5
    }
    final class C5: ComposableEnvironment {
      @Dependency(\.int) var int
    }
    let parent = Parent().with(\.int, 4)
    XCTAssertEqual(parent.c1.c2.c3.c4.c5.int, 4)
    XCTAssertEqual(parent.c1.c2.c3.int, 4)
  }
}
