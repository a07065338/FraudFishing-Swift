//
//  RegisterDTO.swift
//  Fraud Fishing
//
//  Created by Victor Bosquez on 18/09/25.
//

import Foundation

struct UserRegisterRequest: Codable {
    let name: String
    let email: String
    let password: String
}

struct UserRegisterResponse: Decodable {
    let id: String
    let email: String
    let name: String
    let message: String?
}