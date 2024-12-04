//
//  AuthViewModel.swift
//  DrHouseIosAppLast
//
//  Created by Mac2021 on 2/12/2024.
//

import Foundation
class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: String?
    
    func signIn(username: String, password: String, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if username == "test" && password == "test" {
                self.isAuthenticated = true
                self.currentUser = username
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
