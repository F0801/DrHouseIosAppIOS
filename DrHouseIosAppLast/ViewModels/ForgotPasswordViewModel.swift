//
//  ForgotPasswordViewModel.swift
//  DrHouseIosAppLast
//
//  Created by Mac2021 on 2/12/2024.
//

import Foundation
class ForgotPasswordViewModel: ObservableObject {
    @Published var email = ""
    @Published var verificationCode = ""
    @Published var newPassword = ""
    @Published var confirmNewPassword = ""
    @Published var isLoading = false
    @Published var showAlert = false
    @Published var alertMessage = ""
    @Published var currentStep = 1
    @Published var showNewPassword = false
    @Published var showConfirmPassword = false
    
    var headerTitle: String {
        switch currentStep {
        case 1: return "Reset Password"
        case 2: return "Verify Code"
        case 3: return "New Password"
        default: return ""
        }
    }
    
    var headerDescription: String {
        switch currentStep {
        case 1: return "Enter your email address and we'll send you a verification code."
        case 2: return "Enter the verification code we sent to your email."
        case 3: return "Enter your new password."
        default: return ""
        }
    }
    
    var actionButtonTitle: String {
        switch currentStep {
        case 1: return "Send Code"
        case 2: return "Verify Code"
        case 3: return "Reset Password"
        default: return ""
        }
    }
    
    var isActionButtonDisabled: Bool {
        switch currentStep {
        case 1: return email.isEmpty || isLoading
        case 2: return verificationCode.isEmpty || isLoading
        case 3: return newPassword.isEmpty || confirmNewPassword.isEmpty || newPassword != confirmNewPassword || isLoading
        default: return true
        }
    }
    
    func handleActionButton() {
         
            isLoading = true
            
            switch currentStep {
            case 1:
                sendVerificationCode()
            case 2:
                verifyCode()
            case 3:
                resetPassword()
            default:
                break
            }
        
    }
    
    func handleAlertDismissal() {
        if alertMessage.contains("successful") {
            if currentStep < 3 {
                currentStep += 1
            }
        }
    }
    
    private func sendVerificationCode() {
        guard isValidEmail(email) else {
            showError("Please enter a valid email address")
            return
        }
        
        // Simulate API call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.alertMessage = "Verification code has been sent to your email!"
            self.showAlert = true
            self.isLoading = false
        }
    }
    
    private func verifyCode() {
        // Simulate verification
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            if self.verificationCode == "1234" { // Replace with actual verification
                self.alertMessage = "Code verified successfully!"
                self.showAlert = true
            } else {
                self.showError("Invalid verification code")
            }
        }
    }
    
    private func resetPassword() {
        guard isValidPassword(newPassword) else {
            showError("Password must be at least 6 characters long")
            return
        }
        
        guard newPassword == confirmNewPassword else {
            showError("Passwords do not match")
            return
        }
        
        // Simulate password reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.alertMessage = "Password has been reset successfully!"
            self.showAlert = true
            self.isLoading = false
        }
    }
    
    private func showError(_ message: String) {
        alertMessage = message
        showAlert = true
        isLoading = false
    }
    
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
}
