@testable import GlobalEnvironment
import XCTest

fileprivate struct IntKey: DependencyKey {
  static var defaultValue: Int { 1 }
}

fileprivate struct Int1Key: DependencyKey {
  static var defaultValue: Int { -1 }
}

fileprivate struct Int2Key: DependencyKey {
  static var defaultValue: Int { -10 }
}

fileprivate extension Dependencies {
  var int: Int {
    get { self[IntKey.self] }
    set { self[IntKey.self] = newValue }
  }
  
  var int1: Int {
    get { self[Int1Key.self] }
    set { self[Int1Key.self] = newValue }
  }
  
  var int2: Int {
    get { self[Int2Key.self] }
    set { self[Int2Key.self] = newValue }
  }
}

final class GlobalEnvironmentTests: XCTestCase {
  override func setUp() {
    super.setUp()
    Dependencies.global = ._new()
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
}
