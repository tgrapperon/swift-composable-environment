@testable import ComposableEnvironment
import XCTest

final class AnyHashableTypeTests: XCTestCase {
  func testTypeComparison() {
    XCTAssertEqual(AnyHashableType(Int.self), AnyHashableType(Int.self))
    XCTAssertNotEqual(AnyHashableType(String.self), AnyHashableType(Int.self))
  }
  
  func testTypeComparisonWithGenerics() {
    struct Generic<T> {}
    XCTAssertEqual(AnyHashableType(Generic<Int>.self), AnyHashableType(Generic<Int>.self))
    XCTAssertNotEqual(AnyHashableType(Generic<String>.self), AnyHashableType(Generic<Int>.self))
  }
  
  func testTypeComparisonWithClasses() {
    class A {}
    class B: A {}
    XCTAssertEqual(AnyHashableType(A.self), AnyHashableType(A.self))
    XCTAssertNotEqual(AnyHashableType(A.self), AnyHashableType(B.self))
  }
}
