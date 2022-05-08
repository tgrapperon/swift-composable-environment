import XCTest
import _Dependencies

@testable import GlobalEnvironment

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

final class GlobalEnvironmentTests: XCTestCase {
  override func setUp() {
    super.setUp()
    Dependencies.reset()
    Dependencies.clearAliases()
  }

  func testDependency() {
    struct Env: GlobalEnvironment {
      @Dependency(\.int) var int
    }
    let env = Env()
    XCTAssertEqual(env.int, 1)
  }

  func testDependencyImplicitAccess() {
    struct Env: GlobalDependenciesAccessing {}
    let env = Env()
    XCTAssertEqual(env[\.int], 1)
  }

  func testDependenciesOverride() {
    struct Env: GlobalEnvironment {
      @Dependency(\.int) var int
    }
    struct Env2: GlobalEnvironment {
      @Dependency(\.int) var int
    }
    let env = Env().with(\.int, 2)
    XCTAssertEqual(env.int, 2)
    XCTAssertEqual(Env2().int, 2)
  }

  func testDependencyAliasing() {
    struct Parent: GlobalEnvironment {
      @Dependency(\.int) var int
    }
    let parent = Parent()
      .aliasing(\.int1, to: \.int)
      .aliasing(\.int2, to: \.int1)
    XCTAssertEqual(parent[\.int1], 1)
    XCTAssertEqual(parent.with(\.int1, 4).int, 4)
  }

  func testDependencyAliasingViaPropertyWrapper() {
    struct Parent: GlobalEnvironment {
      @Dependency(\.int) var int
      @DerivedEnvironment<Child>(aliases: { $0.alias(\.int1, to: \.int) }) var c1
    }
    struct Child: GlobalEnvironment {
      @Dependency(\.int1) var otherInt
    }
    let parent = Parent()
    XCTAssertEqual(parent.c1.otherInt, 1)
    XCTAssertEqual(parent.with(\.int, 4).c1.otherInt, 4)
  }

  func testRecursiveEnvironment() {
    struct FirstEnvironment: GlobalEnvironment {
      @DerivedEnvironment<SecondEnvironment>
      var second

      @Dependency(\.int1)
      var int1
    }

    struct SecondEnvironment: GlobalEnvironment {
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
