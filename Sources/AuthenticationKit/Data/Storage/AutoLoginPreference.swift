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


final class InMemoryAutoLoginPreference:
    AutoLoginPreference,
    @unchecked Sendable {

    private let lock = NSLock()
    private var value: Bool

    init(
        isEnabled: Bool = false
    ) {
        self.value = isEnabled
    }

    var isEnabled: Bool {
        lock.lock()
        defer { lock.unlock() }
        return value
    }

    func setEnabled(
        _ isEnabled: Bool
    ) {
        lock.lock()
        defer { lock.unlock() }
        value = isEnabled
    }
}
