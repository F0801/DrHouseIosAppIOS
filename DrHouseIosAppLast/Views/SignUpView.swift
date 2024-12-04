import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = SignUpViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.white]),
                         startPoint: .topLeading,
                         endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Create Account")
                            .font(.system(size: 35, weight: .bold))
                        Text("Sign up to get started")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 50)
                    .padding(.bottom, 20)
                    
                    // Input Fields
                    VStack(spacing: 20) {
                        // Full Name field
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                            TextField("Full Name", text: $viewModel.name)
                            if !viewModel.name.isEmpty {
                                Button(action: { viewModel.name = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 5)
                        
                        // Email field
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.gray)
                            TextField("Email", text: $viewModel.email)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .textInputAutocapitalization(.never)
                            if !viewModel.email.isEmpty {
                                Button(action: { viewModel.email = "" }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 5)
                        
                        // Password field
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.gray)
                            if showPassword {
                                TextField("Password", text: $viewModel.password)
                            } else {
                                SecureField("Password", text: $viewModel.password)
                            }
                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 5)
                        
                        // Confirm Password field
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.gray)
                            if showConfirmPassword {
                                TextField("Confirm Password", text: $viewModel.confirmPassword)
                            } else {
                                SecureField("Confirm Password", text: $viewModel.confirmPassword)
                            }
                            Button(action: { showConfirmPassword.toggle() }) {
                                Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: Color.black.opacity(0.1), radius: 5)
                    }
                    .padding(.horizontal)
                    
                    // Sign Up button
                    Button(action: {
                        withAnimation {
                            viewModel.signUp()
                        }
                    }) {
                        ZStack {
                            Text("Sign Up")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.blue)
                                )
                                .opacity(viewModel.isLoading ? 0 : 1)
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.5)
                            }
                        }
                    }
                    .disabled(isSignUpDisabled())
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Already have an account link
                    HStack {
                        Text("Already have an account?")
                            .foregroundColor(.gray)
                        Button(action: {
                            dismiss()
                        }) {
                            Text("Sign In")
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .alert(isPresented: .constant(viewModel.errorMessage != nil)) {
            Alert(
                title: Text("Sign Up Error"),
                message: Text(viewModel.errorMessage ?? ""),
                dismissButton: .default(Text("OK")) {
                    viewModel.errorMessage = nil
                }
            )
        }
        .onChange(of: viewModel.isSignUpSuccessful) { success in
            if success {
                dismiss()
            }
        }
    }
    
    // Helper function
    private func isSignUpDisabled() -> Bool {
        return viewModel.name.isEmpty ||
               viewModel.email.isEmpty ||
               viewModel.password.isEmpty ||
               viewModel.confirmPassword.isEmpty ||
               viewModel.isLoading
    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
    }
}
