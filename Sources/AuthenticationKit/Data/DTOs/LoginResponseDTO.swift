//
//  LoginResponseDTO.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-28.
//

import Foundation

struct LoginResponseDTO: Decodable {
    let user: UserDTO
    let accessToken: String
    let refreshToken: String?
}

struct UserDTO: Decodable {
    let id: String
    let email: String
    let isEmailVerified: Bool

    init(id: String, email: String, isEmailVerified: Bool = false) {
        self.id = id
        self.email = email
        self.isEmailVerified = isEmailVerified
    }

    private enum CodingKeys: String, CodingKey { case id, email, isEmailVerified }

    init(from decoder: any Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(String.self, forKey: .id)
        email = try values.decode(String.self, forKey: .email)
        isEmailVerified = try values.decodeIfPresent(Bool.self, forKey: .isEmailVerified) ?? false
    }
}

extension LoginResponseDTO {

    func toDomain() -> Session {
        Session(
            user: User(
                id: user.id,
                email: user.email,
                isEmailVerified: user.isEmailVerified
            ),
            accessToken: accessToken,
            refreshToken: refreshToken
        )
    }
}


//Example
/*
 {
     "user": {
         "id": "user-1",
         "email": "test@test.com"
     },
     "accessToken": "access-token",
     "refreshToken": "refresh-token"
 }
 */
