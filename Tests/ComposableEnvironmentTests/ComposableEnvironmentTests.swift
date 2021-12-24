@testable import ComposableEnvironment
import XCTest

fileprivate struct IntKey: DependencyKey {
  static var defaultValue: Int { 1 }
}

fileprivate extension _ComposableDependencies {
  var int: Int {
    get { self[IntKey.self] }
    set { self[IntKey.self] = newValue }
  }
}

final class ComposableEnvironmentTests: XCTestCase {
  func test_Dependency() {
    class Env: ComposableEnvironment {
      @_Dependency(\.int) var int
    }
    let env = Env()
    XCTAssertEqual(env.int, 1)
  }
  
  func test_DependencyPropagation() {
    class Parent: ComposableEnvironment {
      @_Dependency(\.int) var int
      @_DerivedEnvironment<Child> var child
    }
    class Child: ComposableEnvironment {
      @_Dependency(\.int) var int
    }
    let parent = Parent()
    XCTAssertEqual(parent.child.int, 1)
    
    let parentWith2 = Parent().with(\.int, 2)
    XCTAssertEqual(parentWith2.int, 2)
    XCTAssertEqual(parentWith2.child.int, 2)
  }
  
  func test_DependencyOverride() {
    class Parent: ComposableEnvironment {
      @_Dependency(\.int) var int
      @_DerivedEnvironment<Child> var child
      @_DerivedEnvironment var sibling = Child().with(\.int, 3)
    }
    class Child: ComposableEnvironment {
      @_Dependency(\.int) var int
    }
    
    let parent = Parent().with(\.int, 2)
    XCTAssertEqual(parent.int, 2)
    XCTAssertEqual(parent.child.int, 2)
    XCTAssertEqual(parent.sibling.int, 3)
  }
  
  func testDerivedWithProperties() {
    class Parent: ComposableEnvironment {
      @_Dependency(\.int) var int
      @_DerivedEnvironment<Child> var child
      @_DerivedEnvironment var sibling = Child(otherInt: 5).with(\.int, 3)
    }
    final class Child: ComposableEnvironment {
      @_Dependency(\.int) var int
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
      @_Dependency(\.int) var int
      @_DerivedEnvironment<C1> var c1
    }
    final class C1: ComposableEnvironment {
      @_DerivedEnvironment<C2> var c2
    }
    final class C2: ComposableEnvironment {
      @_DerivedEnvironment<C3> var c3
    }
    final class C3: ComposableEnvironment {
      @_DerivedEnvironment<C4> var c4
      @_Dependency(\.int) var int
    }
    final class C4: ComposableEnvironment {
      @_DerivedEnvironment<C5> var c5
    }
    final class C5: ComposableEnvironment {
      @_Dependency(\.int) var int
    }
    let parent = Parent().with(\.int, 4)
    XCTAssertEqual(parent.c1.c2.c3.c4.c5.int, 4)
    XCTAssertEqual(parent.c1.c2.c3.int, 4)
  }
  
  func testModifyingDependenciesOncePrimed() {
    class Parent: ComposableEnvironment {
      @_Dependency(\.int) var int
      @_DerivedEnvironment<C1> var c1
    }
    final class C1: ComposableEnvironment {
      @_DerivedEnvironment<C2> var c2
    }
    final class C2: ComposableEnvironment {
      @_DerivedEnvironment<C3> var c3
    }
    final class C3: ComposableEnvironment {
      @_DerivedEnvironment<C4> var c4
      @_Dependency(\.int) var int
    }
    final class C4: ComposableEnvironment {
      @_DerivedEnvironment<C5> var c5
    }
    final class C5: ComposableEnvironment {
      @_Dependency(\.int) var int
    }
    let parent = Parent().with(\.int, 4)
    XCTAssertEqual(parent.c1.c2.c3.int, 4)
    XCTAssertEqual(parent.c1.c2.c3.c4.c5.int, 4)
    // At this stage, the chain is completely primed.
    
    //Update parent with 7
    parent[\.int] = 7
    XCTAssertEqual(parent.c1.c2.c3.c4.c5.int, 7)
    
    //Update c3 with 8
    parent.c1.c2.c3[\.int] = 8
    XCTAssertEqual(parent.c1.c2.c3.c4.c5.int, 8)
    
    //Update parent again with 9
    parent[\.int] = 9
    // c5 should keep c3's value
    XCTAssertEqual(parent.c1.c2.c3.int, 8)
    XCTAssertEqual(parent.c1.c2.c3.c4.c5.int, 8)
  }
}
