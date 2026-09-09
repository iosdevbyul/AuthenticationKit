import Foundation

public struct ResendVerificationEmailUseCase: Sendable {
    private let repository: any AuthenticationRepository

    public init(repository: any AuthenticationRepository) {
        self.repository = repository
    }

    public func execute(email: String) async throws {
        let normalized = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalized.isEmpty else { throw AuthenticationError.invalidInput }
        try await repository.resendVerificationEmail(email: normalized)
    }
}
