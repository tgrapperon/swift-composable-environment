import XCTest

@testable import ComposableEnvironment

extension Dependencies {
  fileprivate var int: Int {
    get { self[\.int] ?? 1 }
    set { self[\.int] = newValue }
  }

  fileprivate var int1: Int {
    get { self[\.int1] ?? -1 }
    set { self[\.int1] = newValue }
  }

  fileprivate var int2: Int {
    get { self[\.int2] ?? -10 }
    set { self[\.int2] = newValue }
  }
}

final class ComposableEnvironmentTests: XCTestCase {
  override func setUp() {
    super.setUp()
    Dependencies.clearAliases()
  }

  func testDependency() {
    class Env: ComposableEnvironment {
      @Dependency(\.int) var int
    }
    let env = Env()
    XCTAssertEqual(env.int, 1)
  }

  func testDependencyImplicitAccess() {
    class Env: ComposableEnvironment {}
    let env = Env()
    XCTAssertEqual(env[\.int], 1)
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

  func testModifyingDependenciesOncePrimed() {
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

  func testDependencyAliasing() {
    class Parent: ComposableEnvironment {
      @Dependency(\.int) var int
    }
    let parent = Parent()
      .aliasing(\.int1, to: \.int)
      .aliasing(\.int2, to: \.int1)
    XCTAssertEqual(parent.int, 1)
    XCTAssertEqual(parent.with(\.int2, 4).int, 4)
    XCTAssertEqual(parent.int1, 4)
  }

  func testDependencyAliasingViaPropertyWrapper() {
    class Parent: ComposableEnvironment {
      @Dependency(\.int) var int
      @DerivedEnvironment<Child>(aliases: { $0.alias(\.int1, to: \.int) }) var c1
    }
    final class Child: ComposableEnvironment {
      @Dependency(\.int1) var otherInt
    }
    let parent = Parent()
    XCTAssertEqual(parent.c1.int1, 1)
    XCTAssertEqual(parent.with(\.int, 4).c1.int1, 4)
  }

  func testRecursiveEnvironment() {
    class FirstEnvironment: ComposableEnvironment {
      @DerivedEnvironment<SecondEnvironment>
      var second

      @Dependency(\.int1)
      var int1
    }

    class SecondEnvironment: ComposableEnvironment {
      @DerivedEnvironment<FirstEnvironment>
      var first

      @Dependency(\.int2)
      var int2
    }

    let first = FirstEnvironment()
    XCTAssertEqual(first.int1, -1)
    XCTAssertEqual(first.second.first.int1, -1)

    XCTAssertEqual(first.second.int2, -10)
    XCTAssertEqual(first.second.first.second.int2, -10)
  }
}
