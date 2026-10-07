import Foundation
import Testing
@testable import AuthenticationKit

struct AutoLoginPreferenceTests {

    @Test
    func defaultsToDisabled() {
        let defaults = makeDefaults()
        let preference =
            UserDefaultsAutoLoginPreference(
                userDefaults: defaults
            )

        #expect(!preference.isEnabled)
    }

    @Test
    func persistsEnabledState() {
        let defaults = makeDefaults()
        let preference =
            UserDefaultsAutoLoginPreference(
                userDefaults: defaults
            )

        preference.setEnabled(true)

        #expect(preference.isEnabled)
    }

    private func makeDefaults() -> UserDefaults {
        let suiteName =
            "AuthenticationKit.AutoLoginPreferenceTests.\(UUID().uuidString)"
        let defaults = UserDefaults(
            suiteName: suiteName
        )!
        defaults.removePersistentDomain(
            forName: suiteName
        )
        return defaults
    }
}
