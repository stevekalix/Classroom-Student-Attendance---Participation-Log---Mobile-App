import XCTest
final class ClassTrackUITests: XCTestCase {
 func testAuthenticationNavigation() {
 let app = XCUIApplication(); app.launchArguments = ["-ui-testing"]; app.launch()
 let email = app.textFields["login.email"]
 XCTAssertTrue(email.waitForExistence(timeout: 10))
 XCTAssertFalse(app.tabBars.firstMatch.exists)
 app.buttons["Create a teacher account"].tap()
 XCTAssertTrue(app.navigationBars["Join ClassTrack"].waitForExistence(timeout: 5))
 app.navigationBars.buttons.element(boundBy: 0).tap()
 XCTAssertTrue(email.waitForExistence(timeout: 5))
 app.buttons["login.submit"].tap()
 XCTAssertTrue(app.staticTexts["Enter a valid email address and password."].waitForExistence(timeout: 5))
 }
}
