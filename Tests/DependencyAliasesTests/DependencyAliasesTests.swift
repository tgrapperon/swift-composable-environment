@testable import DependencyAliases
import XCTest

fileprivate struct Dependencies {
  var int: Int
  var int1: Int
  var int2: Int
}

final class DependencyAliasesTests: XCTestCase {
  func testCanonicalAlias1() {
    var dep = DependencyAliases()
    dep.alias(dependency: \Dependencies.int1, to: \Dependencies.int)
    dep.alias(dependency: \Dependencies.int2, to: \Dependencies.int1)
    XCTAssertEqual(dep.canonicalAlias(for: \Dependencies.int), \.int)
    XCTAssertEqual(dep.canonicalAlias(for: \Dependencies.int1), \.int)
    XCTAssertEqual(dep.canonicalAlias(for: \Dependencies.int2), \.int)
  }
  func testCanonicalAlias2() {
    var dep = DependencyAliases()
    dep.alias(dependency: \Dependencies.int, to: \Dependencies.int1)
    dep.alias(dependency: \Dependencies.int1, to: \Dependencies.int2)
    XCTAssertEqual(dep.canonicalAlias(for: \Dependencies.int), \.int2)
    XCTAssertEqual(dep.canonicalAlias(for: \Dependencies.int1), \.int2)
    XCTAssertEqual(dep.canonicalAlias(for: \Dependencies.int2), \.int2)
  }
  
  func testPreimage() {
    var dep = DependencyAliases()
    dep.alias(dependency: \Dependencies.int1, to: \Dependencies.int)
    dep.alias(dependency: \Dependencies.int2, to: \Dependencies.int1)

    XCTAssertEqual(dep.preimage(for: \Dependencies.int), [\.int, \.int1, \.int2])
    XCTAssertEqual(dep.preimage(for: \Dependencies.int1), [\.int, \.int1, \.int2])
    XCTAssertEqual(dep.preimage(for: \Dependencies.int2), [\.int, \.int1, \.int2])
  }
}
