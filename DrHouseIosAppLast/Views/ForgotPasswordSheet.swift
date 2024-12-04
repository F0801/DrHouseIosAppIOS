import SwiftUI

struct ForgotPasswordSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var isLoading = false
    @State private var message: String?
    @State private var isSuccess = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.3), Color.white]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Reset Password")
                            .font(.system(size: 28, weight: .bold))
                        Text("Enter your email to reset password")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.top, 20)
                    
                    // Email input field
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.gray)
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        if !email.isEmpty {
                            Button(action: { email = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(color: Color.black.opacity(0.1), radius: 5)
                    .padding(.horizontal)
                    
                    // Message display
                    if let message = message {
                        Text(message)
                            .foregroundColor(isSuccess ? .green : .red)
                            .font(.caption)
                    }
                    
                    // Reset Button
                    Button(action: {
                        sendResetEmail()
                    }) {
                        ZStack {
                            Text("Send Reset Link")
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.blue)
                                )
                                .opacity(isLoading ? 0 : 1)
                            
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            }
                        }
                    }
                    .disabled(isLoading || email.isEmpty)
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationBarItems(trailing: Button("Cancel") {
                dismiss()
            })
        }
    }
    
    private func sendResetEmail() {
        isLoading = true
        // Simulate network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
            isSuccess = true
            message = "Reset link has been sent to your email"
            // After 2 seconds, dismiss the sheet
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                dismiss()
            }
        }
    }
}

// Preview provider
struct ForgotPasswordSheet_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPasswordSheet()
    }
}
