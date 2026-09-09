import Foundation

public struct VerifyEmailUseCase: Sendable {
    private let repository: any AuthenticationRepository

    public init(repository: any AuthenticationRepository) {
        self.repository = repository
    }

    public func execute(token: String) async throws {
        guard !token.isEmpty else { throw AuthenticationError.invalidInput }
        try await repository.verifyEmail(token: token)
    }
}
