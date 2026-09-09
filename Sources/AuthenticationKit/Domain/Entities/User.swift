import Foundation

public struct User: Equatable, Codable, Sendable {
    public let id: String
    public let email: String
    public let isEmailVerified: Bool

    public init(id: String, email: String, isEmailVerified: Bool = false) {
        self.id = id
        self.email = email
        self.isEmailVerified = isEmailVerified
    }

    private enum CodingKeys: String, CodingKey {
        case id, email, isEmailVerified
    }

    public init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        email = try values.decode(String.self, forKey: .email)
        // Preserve sessions persisted by versions before email verification.
        isEmailVerified = try values.decodeIfPresent(Bool.self, forKey: .isEmailVerified) ?? false
    }
}
