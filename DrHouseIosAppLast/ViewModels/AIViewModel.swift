// AIViewModel.swift
import Foundation
import Combine


// ViewModel for AI Symptom Analysis
class AIViewModel: ObservableObject {
    @Published var symptomsInput = ""
    @Published var predictionResponse: PredictionResponse? = nil
    @Published var isLoading = false
    @Published var errorMessage: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    func analyzeSymptoms() {
        // Validate symptoms input
        guard !symptomsInput.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter some symptoms"
            return
        }
        
        // Prepare URL
        guard let url = URL(string: "http://172.18.7.103:3000/prediction/symptoms") else {
            errorMessage = "Invalid server URL"
            return
        }
        
        // Prepare symptoms array
        let symptoms = symptomsInput
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
        
        // Prepare request body
        let requestBody: [String: Any] = ["symptoms": symptoms]
        
        // Ensure JSON serialization
        guard let jsonData = try? JSONSerialization.data(withJSONObject: requestBody) else {
            errorMessage = "Failed to prepare request"
            return
        }
        
        // Create URL Request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Set loading state
        isLoading = true
        errorMessage = nil
        
        // Perform network request
        URLSession.shared.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: PredictionResponse.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink { completion in
                self.isLoading = false
                
                switch completion {
                case .failure(let error):
                    self.errorMessage = "Error: \(error.localizedDescription)"
                case .finished:
                    break
                }
            } receiveValue: { response in
                self.predictionResponse = response
            }
            .store(in: &cancellables)
    }
}
