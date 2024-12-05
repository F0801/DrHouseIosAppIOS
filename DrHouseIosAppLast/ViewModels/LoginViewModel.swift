// LoginViewModel.swift
import Foundation
import Combine

class LoginViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var shouldResetNavigation: Bool = false  // Add this property
    
    @Published var isReclamationSubmitted: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private let baseURL = "http://192.168.39.48:3000"
    
    init() {
        // Check authentication status when ViewModel is initialized
        checkAuthenticationStatus()
    }
    
    func checkAuthenticationStatus() {
        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken"),
              let refreshToken = UserDefaults.standard.string(forKey: "refreshToken"),
              !accessToken.isEmpty else {
            DispatchQueue.main.async {
                self.isAuthenticated = false
            }
            return
        }
        
        // Validate token and refresh if needed
        validateAndRefreshToken(accessToken: accessToken, refreshToken: refreshToken)
    }
    
    private func validateAndRefreshToken(accessToken: String, refreshToken: String) {
        // Create URL for token validation/refresh
        guard let url = URL(string: "\(baseURL)/auth/refresh") else {
            handleError(LoginError.invalidURL)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let refreshData = ["refreshToken": refreshToken]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: refreshData) else {
            handleError(LoginError.invalidRequestBody)
            return
        }
        
        request.httpBody = httpBody
        
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { data, response -> Data in
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
            .decode(type: LoginResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .failure(let error):
                        self?.handleTokenRefreshError(error)
                    case .finished:
                        break
                    }
                },
                receiveValue: { [weak self] response in
                    self?.handleSuccessfulTokenRefresh(response)
                }
            )
            .store(in: &cancellables)
    }
    
    private func handleSuccessfulTokenRefresh(_ response: LoginResponse) {
           DispatchQueue.main.async {
               // Update tokens in UserDefaults
               UserDefaults.standard.set(response.accestoken, forKey: "accessToken")
               UserDefaults.standard.set(response.refreshToken, forKey: "refreshToken")
               UserDefaults.standard.set(response.userId, forKey: "userId")
               
               // Reset navigation if needed
               self.shouldResetNavigation = true
               
               // Update authentication state
               self.isAuthenticated = true
               self.errorMessage = nil
               
               // Reset the navigation flag
               DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                   self.shouldResetNavigation = false
               }
           }
       }
    
    private func handleTokenRefreshError(_ error: Error) {
        DispatchQueue.main.async {
            // Clear stored tokens on refresh error
            self.logout()
        }
    }
    
    func login() {
        guard !isLoading else { return }
        guard isInputValid else {
            errorMessage = "Please enter a valid email and password"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        guard let url = URL(string: "\(baseURL)/auth/login") else {
            handleError(LoginError.invalidURL)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let loginData = ["email": email, "password": password]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: loginData) else {
            handleError(LoginError.invalidRequestBody)
            return
        }
        
        request.httpBody = httpBody
        
        URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { [weak self] data, response -> Data in
                guard let self = self else { throw LoginError.invalidResponse }
                
                self.logResponse(data: data, response: response)
                
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
            .decode(type: LoginResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.handleError(error)
                    }
                },
                receiveValue: { [weak self] response in
                    self?.handleSuccessfulLogin(response)
                }
            )
            .store(in: &cancellables)
    }
    
    func logout() {
            UserDefaults.standard.removeObject(forKey: "accessToken")
            UserDefaults.standard.removeObject(forKey: "refreshToken")
            UserDefaults.standard.removeObject(forKey: "userId")
            
            DispatchQueue.main.async {
                self.shouldResetNavigation = true  // Set this before changing authentication
                self.isAuthenticated = false
                self.email = ""
                self.password = ""
                self.errorMessage = nil
                self.isLoading = false
                // Reset the flag after a short delay to allow for multiple logout/login cycles
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.shouldResetNavigation = false
                }
            }
        }
    var isInputValid: Bool {
        !email.isEmpty && email.contains("@") && password.count >= 6
    }
    
    private func handleSuccessfulLogin(_ response: LoginResponse) {
            DispatchQueue.main.async {
                // First store the tokens
                UserDefaults.standard.set(response.accestoken, forKey: "accessToken")
                UserDefaults.standard.set(response.refreshToken, forKey: "refreshToken")
                UserDefaults.standard.set(response.userId, forKey: "userId")
                
                // Reset any previous navigation state
                self.shouldResetNavigation = true
                
                // Then update the authentication state
                self.isAuthenticated = true
                self.errorMessage = nil
                
                // Reset the navigation flag
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.shouldResetNavigation = false
                }
                
                print("Login successful!")
                print("User ID: \(response.userId)")
            }
        }
    
    private func handleError(_ error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false
            if let loginError = error as? LoginError {
                self.errorMessage = loginError.errorDescription
            } else {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    private func logResponse(data: Data, response: URLResponse) {
        #if DEBUG
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw JSON response: \(jsonString)")
        }
        if let httpResponse = response as? HTTPURLResponse {
            print("Response status code: \(httpResponse.statusCode)")
        }
        #endif
    }
    
    func submitReclamation(subject: String, reclamationText: String) {
            // Validate inputs
            guard !subject.isEmpty, !reclamationText.isEmpty else {
                self.errorMessage = "All fields are required."
                return
            }
            
            // Retrieve the user ID from UserDefaults
        DispatchQueue.main.async {
            if let userId = UserDefaults.standard.string(forKey: "userId") {
                print("User ID retrieved: \(userId)")
            } else {
                print("User ID not found in UserDefaults.")
            }
        }

        
            guard let userId = UserDefaults.standard.string(forKey: "userId") else {
                self.errorMessage = "User ID not found. Please log in again."
                return
            }
            
            // Create the reclamation object
            let newReclamation = Reclamation(user: userId, subject: subject, reclamationText: reclamationText)
            
            // Prepare the API URL
            guard let url = URL(string: "https://192.168.39.48:3000/reclamations") else {
                self.errorMessage = "Invalid API URL."
                return
            }
            
            // Encode the reclamation object into JSON
            guard let jsonData = try? JSONEncoder().encode(newReclamation) else {
                self.errorMessage = "Failed to encode data."
                return
            }
            
            // Create the API request
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = jsonData
            
            // Update UI state to indicate loading
            self.isLoading = true
            
            // Perform the network request
            URLSession.shared.dataTaskPublisher(for: request)
                .tryMap { output -> Data in
                    guard let response = output.response as? HTTPURLResponse,
                          (200...299).contains(response.statusCode) else {
                        throw URLError(.badServerResponse)
                    }
                    return output.data
                }
                .decode(type: Reclamation.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { [weak self] completion in
                    guard let self = self else { return }
                    self.isLoading = false
                    
                    switch completion {
                    case .failure(let error):
                        self.errorMessage = "Failed to submit reclamation: \(error.localizedDescription)"
                    case .finished:
                        break
                    }
                }, receiveValue: { [weak self] _ in
                    guard let self = self else { return }
                    self.isReclamationSubmitted = true
                })
                .store(in: &cancellables)
        }
    
}
