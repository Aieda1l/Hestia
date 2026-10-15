import XCTest

final class ProjectUITestSmoke: XCTestCase {
    func testAppLaunchesToForeground() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 10))
    }
}
