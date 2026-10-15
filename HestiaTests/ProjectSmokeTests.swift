import XCTest
@testable import Hestia

final class ProjectSmokeTests: XCTestCase {
    func testAppCompilesWithOriginalMascotIdentifier() {
        XCTAssertEqual(StarterCompanion.id, "starter-orb")
    }
}
