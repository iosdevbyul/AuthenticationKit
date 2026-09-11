//
//  EmailChangeDTOs.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-11.
//

import Foundation

struct RequestEmailChangeRequestDTO: Encodable {
    let currentPassword: String
    let newEmail: String
}

struct ConfirmEmailChangeRequestDTO: Encodable {
    let token: String
}
