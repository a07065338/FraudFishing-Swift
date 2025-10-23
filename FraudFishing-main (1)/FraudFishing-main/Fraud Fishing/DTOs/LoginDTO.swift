//
//  LoginDTO.swift
//  TemplateReto451
//
//  Created by Usuario on 09/09/25.
//

import Foundation

struct UserLoginRequest: Codable {
    let email: String 
    let password: String
}


struct User: Codable {
    let id: Int
    let email: String
    let name: String
    let is_admin: Int
    let is_super_admin: Int
}

struct UserLoginResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let user: User
}
