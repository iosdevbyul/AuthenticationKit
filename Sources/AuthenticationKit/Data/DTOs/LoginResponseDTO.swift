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
}

extension LoginResponseDTO {

    func toDomain() -> Session {
        Session(
            user: User(
                id: user.id,
                email: user.email
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
