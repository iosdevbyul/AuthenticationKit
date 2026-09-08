//
//  ChangePasswordRequestDTO.swift
//  AuthenticationKit
//
//  Created by COMATOKI on 2026-09-08.
//

import Foundation

struct ChangePasswordRequestDTO: Encodable {
    let currentPassword: String
    let newPassword: String
}
