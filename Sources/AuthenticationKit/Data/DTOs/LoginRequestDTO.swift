//
//  LoginRequestDTO.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-08-28.
//

import Foundation

struct LoginRequestDTO: Encodable {
    let email: String
    let password: String
}
