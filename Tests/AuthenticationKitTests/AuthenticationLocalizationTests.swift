import XCTest
@testable import AuthenticationKit

final class AuthenticationLocalizationTests:
    XCTestCase {

    func testLocalizationResourceResolves() {
        let value =
            AuthL10n.string(
                "auth.login"
            )

        XCTAssertFalse(
            value.isEmpty
        )

        XCTAssertNotEqual(
            value,
            "auth.login"
        )
    }
}
