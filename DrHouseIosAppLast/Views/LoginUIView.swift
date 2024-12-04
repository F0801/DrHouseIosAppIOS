import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var navigationPath = NavigationPath()
    @State private var showForgotPassword = false // Add this line
    @Environment(\.colorScheme) var colorScheme
    @State private var isPasswordVisible = false
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                // Background gradient matching SignUpView style
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.white]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 8) {
                            Text("Welcome Back")
                                .font(.system(size: 35, weight: .bold))
                            Text("Sign in to continue")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 50)
                        .padding(.bottom, 20)
                        
                        // Input Fields
                        VStack(spacing: 20) {
                            // Email field
                            HStack {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(.gray)
                                TextField("Email", text: $viewModel.email)
                                    .keyboardType(.emailAddress)
                                    .autocapitalization(.none)
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
                                if isPasswordVisible {
                                    TextField("Password", text: $viewModel.password)
                                } else {
                                    SecureField("Password", text: $viewModel.password)
                                }
                                Button(action: { isPasswordVisible.toggle() }) {
                                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(color: Color.black.opacity(0.1), radius: 5)
                            
                            // Forgot Password Link
                            HStack {
                                Spacer()
                                Button("Forgot Password?") {
                                    showForgotPassword = true // This triggers the sheet
                                }
                                .font(.footnote)
                                .foregroundColor(.blue)
                            }
                            .padding(.horizontal, 4)}
                        .sheet(isPresented: $showForgotPassword) {
                                        ForgotPasswordSheet()
                                            .presentationDetents([.height(600)]) // Adjust height as needed
                                            .presentationDragIndicator(.visible)
                                    }
                                            
                        // Error Message
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .font(.caption)
                                .padding(.top, 5)
                        }
                        
                        // Login Button
                        Button(action: {
                            withAnimation {
                                viewModel.login()
                            }
                        }) {
                            ZStack {
                                Text("Sign In")
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
                        .disabled(viewModel.isLoading)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        // Divider with "OR"
                        HStack {
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.3))
                            
                            Text("OR")
                                .font(.footnote)
                                .foregroundColor(.gray)
                            
                            Rectangle()
                                .frame(height: 1)
                                .foregroundColor(.gray.opacity(0.3))
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 20)
                        
                        // Sign Up Button
                        Button {
                            navigationPath.append("signup")
                        } label: {
                            Text("Create New Account")
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(color: Color.black.opacity(0.1), radius: 5)
                        }
                        .padding(.horizontal)
                    }
                    .padding()
                }
            }
            .navigationBarHidden(true)
            .onChange(of: viewModel.isAuthenticated) { newValue in
                if newValue {
                    withAnimation {
                        navigationPath.append("home")
                    }
                }
            }
            .navigationDestination(for: String.self) { route in
                switch route {
                case "home":
                    HomeView(navigationPath: $navigationPath)
                        .navigationBarBackButtonHidden()
                case "signup":
                    SignUpView()
                default:
                    EmptyView()
                }
            }
        }
        .onAppear {
            viewModel.checkAuthenticationStatus()
        }
    }
}
