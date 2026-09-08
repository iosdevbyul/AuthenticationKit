import Foundation

public struct ResetPasswordUseCase: Sendable {
    private let repository: any AuthenticationRepository

    public init(repository: any AuthenticationRepository) {
        self.repository = repository
    }

    public func execute(token: String, newPassword: String) async throws {
        try await repository.resetPassword(token: token, newPassword: newPassword)
    }
}
