//
//  ReclamationViewModel.swift
//  DrHouseIosAppLast
//
//  Created by Mac2021 on 4/12/2024.
//

import Foundation
import Combine

class ReclamationViewModel: ObservableObject {
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var isReclamationSubmitted: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    /// Submits a new reclamation to the backend API.
    /// - Parameters:
    ///   - subject: The subject of the reclamation.
    ///   - reclamationText: Detailed text describing the reclamation.
    func submitReclamation(subject: String, reclamationText: String) {
            // Validate inputs
            guard !subject.isEmpty, !reclamationText.isEmpty else {
                self.errorMessage = "All fields are required."
                return
            }
            
            // Retrieve the user ID from UserDefaults
        DispatchQueue.main.async {
            if let userId = UserDefaults.standard.string(forKey: "USER_ID") {
                print("User ID retrieved: \(userId)")
            } else {
                print("User ID not found in UserDefaults.")
            }
        }

        
            guard let userId = UserDefaults.standard.string(forKey: "USER_ID") else {
                self.errorMessage = "User ID not found. Please log in again."
                return
            }
            
            // Create the reclamation object
            let newReclamation = Reclamation(user: userId, title: subject, description: reclamationText)
            
            // Prepare the API URL
            guard let url = URL(string: "https://172.18.7.103:3000/reclamations") else {
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

