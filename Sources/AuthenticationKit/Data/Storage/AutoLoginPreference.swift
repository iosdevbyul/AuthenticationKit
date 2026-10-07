import Foundation

protocol AutoLoginPreference: Sendable {
    var isEnabled: Bool { get }
    func setEnabled(_ isEnabled: Bool)
}

final class UserDefaultsAutoLoginPreference:
    AutoLoginPreference,
    @unchecked Sendable {

    private let userDefaults: UserDefaults
    private let key = "AuthenticationKit.autoLoginEnabled"

    init(
        userDefaults: UserDefaults = .standard
    ) {
        self.userDefaults = userDefaults
    }

    var isEnabled: Bool {
        userDefaults.bool(forKey: key)
    }

    func setEnabled(
        _ isEnabled: Bool
    ) {
        userDefaults.set(
            isEnabled,
            forKey: key
        )
    }
}
