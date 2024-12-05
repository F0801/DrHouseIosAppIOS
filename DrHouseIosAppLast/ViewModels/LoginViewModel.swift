import Foundation
import Combine

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var shouldResetNavigation: Bool = false
    @Published var isFirstLogin: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private let baseURL = "http://172.18.7.103:3000"
    
    init() {
        // Simply check if we have a stored token
        
    }
    
    // MARK: - Authentication Check
    func checkAuthenticationStatus() {
        // Simply check if we have stored credentials
        let hasToken = UserDefaults.standard.string(forKey: "accessToken") != nil
        let hasUserId = UserDefaults.standard.string(forKey: "USER_ID") != nil
        isAuthenticated = hasToken && hasUserId
        
        print("🔍 Checking stored credentials...")
        print("Has Token: \(hasToken)")
        print("Has UserID: \(hasUserId)")
        print("Is Authenticated: \(isAuthenticated)")
    }
    
    // MARK: - Login
    func login() {
        guard !isLoading, isInputValid else {
            errorMessage = "Please provide a valid email and password."
            return
        }

        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            handleError(LoginError.invalidURL)
            return
        }

        let requestBody = ["email": email, "password": password]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: requestBody)

        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap(validateResponse)
            .decode(type: LoginResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.handleError(error)
                }
            }, receiveValue: { [weak self] response in
                self?.handleSuccessfulLogin(response)
            })
            .store(in: &cancellables)
    }
    
    private func handleSuccessfulLogin(_ response: LoginResponse) {
            print("🔐 Login successful")
            print("🔑 Access Token: \(response.accestoken)")
            print("👤 UserID: \(response.userId)")
            
            // Store credentials
            UserDefaults.standard.set(response.accestoken, forKey: "accessToken")
            UserDefaults.standard.set(response.refreshToken, forKey: "refreshToken")
            UserDefaults.standard.set(response.userId, forKey: "USER_ID")
            UserDefaults.standard.set(response.isFirstLogin, forKey: "isFirstLogin")

            // Verify storage
            print("✅ Stored Access Token: \(UserDefaults.standard.string(forKey: "accessToken") ?? "Failed to store")")
            print("✅ Stored UserID: \(UserDefaults.standard.string(forKey: "USER_ID") ?? "Failed to store")")

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.isFirstLogin = response.isFirstLogin
                self.isAuthenticated = true
                self.shouldResetNavigation = true
                
                // Reset navigation flag after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.shouldResetNavigation = false
                }
            }
        }
    func clearStoredCredentials() {
            print("🗑️ Clearing all stored credentials...")
            
            // Clear all authentication related data
            UserDefaults.standard.removeObject(forKey: "accessToken")
            UserDefaults.standard.removeObject(forKey: "refreshToken")
            UserDefaults.standard.removeObject(forKey: "USER_ID")
            UserDefaults.standard.removeObject(forKey: "isFirstLogin")
            
            // Verify removal
            print("✅ Credentials cleared:")
            print("Access Token: \(UserDefaults.standard.string(forKey: "accessToken") ?? "Removed")")
            print("UserID: \(UserDefaults.standard.string(forKey: "USER_ID") ?? "Removed")")
            
            // Reset view model state
            self.isAuthenticated = false
            self.email = ""
            self.password = ""
            self.errorMessage = nil
            self.isFirstLogin = false
        }
    
    // MARK: - Logout
    func logout() {
        print("🔄 Logging out...")
        UserDefaults.standard.removeObject(forKey: "accessToken")
        UserDefaults.standard.removeObject(forKey: "refreshToken")
        UserDefaults.standard.removeObject(forKey: "USER_ID")
        UserDefaults.standard.removeObject(forKey: "isFirstLogin")
        
        print("❌ Access Token after logout: \(UserDefaults.standard.string(forKey: "accessToken") ?? "Removed")")
        print("❌ UserID after logout: \(UserDefaults.standard.string(forKey: "USER_ID") ?? "Removed")")
        
        self.isAuthenticated = false
        self.email = ""
        self.password = ""
        self.errorMessage = nil
        self.shouldResetNavigation = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.shouldResetNavigation = false
        }
    }
    
    // MARK: - Helpers
    private var isInputValid: Bool {
        return !email.isEmpty && email.contains("@") && password.count >= 6
    }

    private func handleError(_ error: Error) {
        self.errorMessage = (error as? LoginError)?.errorDescription ?? error.localizedDescription
    }
    
    private func validateResponse(data: Data, response: URLResponse) throws -> Data {
        guard let httpResponse = response as? HTTPURLResponse else {
            throw LoginError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return data
        case 401:
            throw LoginError.invalidCredentials
        default:
            throw LoginError.serverError(httpResponse.statusCode)
        }
    }
    
    func checkStoredCredentials() {
        print("🔍 Checking stored credentials...")
        print("Access Token: \(UserDefaults.standard.string(forKey: "accessToken") ?? "None")")
        print("UserID: \(UserDefaults.standard.string(forKey: "USER_ID") ?? "None")")
        print("Is Authenticated: \(isAuthenticated)")
    }
}
