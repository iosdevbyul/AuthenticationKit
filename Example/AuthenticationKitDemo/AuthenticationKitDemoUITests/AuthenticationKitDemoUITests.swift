import XCTest

final class AuthenticationKitDemoUITests: XCTestCase {
    @MainActor
    func testDemoSignupLoginRefreshAndWithdraw() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launch()
        let email = "ui-" + UUID().uuidString.lowercased() + "@example.com"
        let password = "DemoPassword123!"
        app.buttons["Sign Up"].tap()
        let emailField = app.textFields["이메일을 입력해주세요."]
        XCTAssertTrue(emailField.waitForExistence(timeout: 10))
        emailField.tap()
        emailField.typeText(email)
        typePassword(
            password,
            placeholder: "비밀번호를 입력해주세요.",
            app: app
        )

        typePassword(
            password,
            placeholder: "비밀번호를 다시 입력해주세요.",
            app: app
        )
        app.swipeUp()
        app.buttons["회원가입"].tap()
        XCTAssertTrue(app.staticTexts["Sign up succeeded"].waitForExistence(timeout: 15),
                      app.staticTexts.allElementsBoundByIndex.map(\.label).joined(separator: "; "))
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.staticTexts[email].waitForExistence(timeout: 15))
        app.buttons["Current User"].tap()
        XCTAssertTrue(app.staticTexts["Current user: " + email].waitForExistence(timeout: 15))
        app.buttons["Refresh Session"].tap()
        XCTAssertTrue(app.staticTexts["Session refreshed"].waitForExistence(timeout: 15))
        app.buttons["Logout"].tap()
        XCTAssertTrue(app.staticTexts["Logged out"].waitForExistence(timeout: 15))
        app.buttons["Login"].tap()
        app.textFields["이메일을 입력해주세요."].tap()
        app.textFields["이메일을 입력해주세요."].typeText(email)
        typePassword(
            password,
            placeholder: "비밀번호를 입력해주세요.",
            app: app
        )
        app.swipeUp()
        app.buttons["로그인"].tap()
        XCTAssertTrue(app.staticTexts["Login succeeded"].waitForExistence(timeout: 15),
                      app.staticTexts.allElementsBoundByIndex.map(\.label).joined(separator: "; "))
        app.navigationBars.buttons.element(boundBy: 0).tap()
        XCTAssertTrue(app.staticTexts[email].waitForExistence(timeout: 15))
        app.swipeUp()
        app.buttons["Withdraw"].tap()
        XCTAssertTrue(app.staticTexts["Account withdrawn"].waitForExistence(timeout: 15))
    }
    
    @MainActor
    private func typePassword(
        _ password: String,
        placeholder: String,
        app: XCUIApplication
    ) {
        app.buttons["Show password"].firstMatch.tap()

        let field = app.textFields[placeholder]

        XCTAssertTrue(field.waitForExistence(timeout: 5))

        field.tap()
        field.typeText(password)

        XCTAssertEqual(
            (field.value as? String)?.count,
            password.count
        )
    }
}
