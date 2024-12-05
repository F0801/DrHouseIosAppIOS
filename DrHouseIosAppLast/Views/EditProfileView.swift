//
//  EditProfileView.swift
//  DrHouseIosAppLast
//
//  Created by Mac2021 on 4/12/2024.
//

import SwiftUI

struct EditProfileView: View {
    @State private var username: String = "JohnDoe"
    @State private var email: String = "johndoe@example.com"
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.white]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            VStack(spacing: 25) {
                // Header
                VStack(spacing: 8) {
                    Text("Edit Profile")
                        .font(.system(size: 35, weight: .bold))
                    Text("Update your details")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 50)
                .padding(.bottom, 20)
                
                // Profile Editing Section
                VStack(spacing: 20) {
                    // Username field
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                        TextField("Username", text: $username)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                    
                    // Email field
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.gray)
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .textInputAutocapitalization(.never)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 10)
                
                // Save Button
                Button(action: {
                    saveProfile()
                }) {
                    Text("Save")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 180)
                        .background(Color.blue.opacity(0.6))
                        .cornerRadius(50)
                }
                
                Button(action: {
                    saveProfile()
                }) {
                    Text("Change Password")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 180)
                        .background(Color.yellow.opacity(1))
                        .cornerRadius(50)
                }
            }
        }
    }
    
    // Save profile changes
    private func saveProfile() {
        // Add your save logic here (e.g., save to database, update user data, etc.)
        print("Profile saved with Username: \(username), Email: \(email)")
    }
}

struct EditProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditProfileView()
    }
}
