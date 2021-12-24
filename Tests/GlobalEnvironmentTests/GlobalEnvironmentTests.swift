@testable import GlobalEnvironment
import XCTest

private struct IntKey: DependencyKey {
  static var defaultValue: Int { 1 }
}

private extension Dependencies {
  var int: Int {
    get { self[IntKey.self] }
    set { self[IntKey.self] = newValue }
  }
}

final class GlobalEnvironmentTests: XCTestCase {
  override func setUp() {
    super.setUp()
    Dependencies.global = ._new()
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
}
