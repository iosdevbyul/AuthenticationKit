//
//  SignUpRequestDTO.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-29.
//

import Foundation

struct SignUpRequestDTO: Encodable {
    let email: String
    let password: String
}
