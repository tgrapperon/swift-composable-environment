import XCTest

@testable import _DependencyAliases

private struct Dependencies {
  var int: Int
  var int1: Int
  var int2: Int
}

final class DependencyAliasesTests: XCTestCase {
  func testStandardAlias1() {
    var dep = DependencyAliases()
    dep.alias(dependency: \Dependencies.int1, to: \Dependencies.int)
    dep.alias(dependency: \Dependencies.int2, to: \Dependencies.int1)
    XCTAssertEqual(dep.standardAlias(for: \Dependencies.int), \.int)
    XCTAssertEqual(dep.standardAlias(for: \Dependencies.int1), \.int)
    XCTAssertEqual(dep.standardAlias(for: \Dependencies.int2), \.int)
  }
  func testStandardAlias2() {
    var dep = DependencyAliases()
    dep.alias(dependency: \Dependencies.int, to: \Dependencies.int1)
    dep.alias(dependency: \Dependencies.int1, to: \Dependencies.int2)
    XCTAssertEqual(dep.standardAlias(for: \Dependencies.int), \.int2)
    XCTAssertEqual(dep.standardAlias(for: \Dependencies.int1), \.int2)
    XCTAssertEqual(dep.standardAlias(for: \Dependencies.int2), \.int2)
  }

  func testAliasesForDependency() {
    var dep = DependencyAliases()
    dep.alias(dependency: \Dependencies.int1, to: \Dependencies.int)
    dep.alias(dependency: \Dependencies.int2, to: \Dependencies.int1)

    XCTAssertEqual(dep.aliasing(with: \Dependencies.int), [\.int, \.int1, \.int2])
    XCTAssertEqual(dep.aliasing(with: \Dependencies.int1), [\.int, \.int1, \.int2])
    XCTAssertEqual(dep.aliasing(with: \Dependencies.int2), [\.int, \.int1, \.int2])
  }

  //  func testCyclicDependencyRaiseBreakpoint() {
  //    var dep = DependencyAliases()
  //    dep.alias(dependency: \Dependencies.int, to: \Dependencies.int1)
  //    dep.alias(dependency: \Dependencies.int1, to: \Dependencies.int)
  //    _ = dep.standardAlias(for: \Dependencies.int)
  //  }
}
