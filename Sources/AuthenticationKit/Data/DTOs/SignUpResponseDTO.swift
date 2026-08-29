//
//  SignUpResponseDTO.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-29.
//

import Foundation

struct SignUpResponseDTO: Decodable {
    let user: UserDTO
    let accessToken: String
    let refreshToken: String?
}

extension SignUpResponseDTO {

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
