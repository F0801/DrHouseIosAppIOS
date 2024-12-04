//
//  UserModel.swift
//  DrHouseIosAppLast
//
//  Created by Mac2021 on 2/12/2024.
//

import Foundation

struct User:Codable{
    var name : String
    var email : String
    var password : String
}



struct LoginRequest: Codable{
    var email: String
    var password : String
}

struct LoginResponse: Decodable {
    let accestoken: String
    let refreshToken: String
    let userId: String
    let isFirstLogin:Bool
}
struct SignupResponse: Decodable {
    let message: String
}


enum LoginError: Error {
    case invalidURL
    case invalidRequestBody
    case networkError(String)
    case invalidResponse
    case invalidCredentials
    case serverError(Int)
}

extension LoginError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid server URL"
        case .invalidRequestBody:
            return "Failed to create request"
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidResponse:
            return "Invalid server response"
        case .invalidCredentials:
            return "Invalid email or password"
        case .serverError(let code):
            return "Server error (Code: \(code))"
        }
    }
}
