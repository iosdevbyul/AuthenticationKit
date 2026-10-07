import Foundation
import XCTest
@testable import AuthenticationKit

final class AuthenticationLocalizationTests:
    XCTestCase {

    func testEnglishLocalizationUsesEnglishText() throws {
        let bundle =
            try localizedBundle(
                language: "en"
            )

        XCTAssertEqual(
            bundle.localizedString(
                forKey: "auth.login",
                value: nil,
                table: nil
            ),
            "Log In"
        )

        XCTAssertEqual(
            bundle.localizedString(
                forKey:
                    "auth.session.title",
                value: nil,
                table: nil
            ),
            "Login Sessions"
        )
    }

    func testKoreanLocalizationUsesKoreanText() throws {
        let bundle =
            try localizedBundle(
                language: "ko"
            )

        XCTAssertEqual(
            bundle.localizedString(
                forKey: "auth.login",
                value: nil,
                table: nil
            ),
            "로그인"
        )

        XCTAssertEqual(
            bundle.localizedString(
                forKey:
                    "auth.session.title",
                value: nil,
                table: nil
            ),
            "로그인 세션"
        )
    }

    private func localizedBundle(
        language: String
    ) throws -> Bundle {
        let path = try XCTUnwrap(
            Bundle.module.path(
                forResource: language,
                ofType: "lproj"
            )
        )

        return try XCTUnwrap(
            Bundle(path: path)
        )
    }
}
