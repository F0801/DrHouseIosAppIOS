import Foundation
import Combine

class SignUpViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isSignUpSuccessful: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    private let baseURL = "http://172.18.7.103:3000"
    
    // Input validation
    func isValidInput() -> Bool {
        // Check if fields are not empty
        guard !name.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
            errorMessage = "All fields are required"
            return false
        }
        
        // Validate email format
        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address"
            return false
        }
        
        // Check password length
        guard password.count >= 6 else {
            errorMessage = "Password must be at least 6 characters long"
            return false
        }
        
        // Check if passwords match
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match"
            return false
        }
        
        return true
    }
    
    // Email validation
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    // Sign up function
    func signUp() {
        // Reset error message
        errorMessage = nil
        
        // Validate input
        guard isValidInput() else {
            return
        }
        
        // Set loading state
        isLoading = true
        
        // Create user object
        let user = User(
            name: name,
            email: email,
            password: password
        )
        
        // Create URL
        guard let url = URL(string: "\(baseURL)/auth/signup") else {
            handleError(LoginError.invalidURL)
            return
        }
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Encode user data
        guard let encodedUser = try? JSONEncoder().encode(user) else {
            handleError(LoginError.invalidRequestBody)
            return
        }
        
        request.httpBody = encodedUser
        
        // Make network request
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw LoginError.invalidResponse
                }
                
                // Log response for debugging
                self.logResponse(data: data, response: httpResponse)
                
                switch httpResponse.statusCode {
                case 200...299:
                    return data
                case 400:
                    throw LoginError.invalidCredentials
                default:
                    throw LoginError.serverError(httpResponse.statusCode)
                }
            }
            .decode(type: SignupResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self?.handleError(error)
                }
            } receiveValue: { [weak self] response in
                self?.handleSuccessfulSignup(response)
            }
            .store(in: &cancellables)
    }
    
    // Handle successful signup
    private func handleSuccessfulSignup(_ response: SignupResponse) {
        isSignUpSuccessful = true
        errorMessage = nil
        // Clear form data
        clearForm()
    }
    
    // Handle errors
    private func handleError(_ error: Error) {
        isLoading = false
        if let loginError = error as? LoginError {
            errorMessage = loginError.errorDescription
        } else {
            errorMessage = error.localizedDescription
        }
    }
    
    // Clear form data
    private func clearForm() {
        name = ""
        email = ""
        password = ""
        confirmPassword = ""
    }
    
    // Debug logging
    private func logResponse(data: Data, response: HTTPURLResponse) {
        #if DEBUG
        print("Response status code: \(response.statusCode)")
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw JSON response: \(jsonString)")
        }
        #endif
    }
    
    // Reset state
    func reset() {
        clearForm()
        errorMessage = nil
        isLoading = false
        isSignUpSuccessful = false
    }
}
