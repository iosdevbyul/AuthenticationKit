import Foundation

struct VerifyEmailRequestDTO: Encodable {
    let token: String
}

struct ResendVerificationEmailRequestDTO: Encodable {
    let email: String
}

struct EmailVerificationResponseDTO: Decodable {
    let message: String
}
