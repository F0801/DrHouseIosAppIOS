//
//  DrHouseIosAppLastApp.swift
//  DrHouseIosAppLast
//
//  Created by Mac2021 on 2/12/2024.
//

import SwiftUI

@main
struct LoginApp: App {
    
    @StateObject private var loginViewModel = LoginViewModel()
        
        init() {
            // Clear credentials on app launch
            UserDefaults.standard.removeObject(forKey: "accessToken")
            UserDefaults.standard.removeObject(forKey: "refreshToken")
            UserDefaults.standard.removeObject(forKey: "USER_ID")
            UserDefaults.standard.removeObject(forKey: "isFirstLogin")
            print("🗑️ Cleared all stored credentials on app launch")
        }
    var body: some Scene {
        WindowGroup {
            
            LoginView()
        }
    }
}
