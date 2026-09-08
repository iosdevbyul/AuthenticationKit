import Foundation

public struct RefreshSessionUseCase: Sendable {
    private let repository: any AuthenticationRepository
    private let sessionManager: SessionManager

    public init(repository: any AuthenticationRepository, sessionManager: SessionManager) {
        self.repository = repository
        self.sessionManager = sessionManager
    }

    public func execute() async throws -> Session {
        guard let token = sessionManager.currentSession?.refreshToken, !token.isEmpty else {
            throw AuthenticationError.invalidCredentials
        }
        let session = try await repository.refresh(refreshToken: token)
        try sessionManager.setSession(session)
        return session
    }
}
