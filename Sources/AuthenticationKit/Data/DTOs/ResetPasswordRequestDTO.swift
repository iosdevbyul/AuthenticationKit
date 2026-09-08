import Foundation

struct ResetPasswordRequestDTO: Encodable {
    let token: String
    let newPassword: String
}
