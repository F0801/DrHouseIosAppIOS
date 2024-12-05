import Foundation
import Combine

class ProfileViewModel: ObservableObject {
    @Published var user: User? // Holds the user data
    @Published var isLoading = false // Shows a loading indicator if needed
    @Published var errorMessage: String? // For error handling
    
    

    private var cancellables = Set<AnyCancellable>()
    
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: "accessToken") // Get the stored access token
    }
    private var userid: String? {
        return UserDefaults.standard.string(forKey: "USER_ID") // Get the stored access token
    }
    
    func fetchUserData() {
        guard let token = accessToken else {
            self.errorMessage = "No access token found"
            return
        }
        
        guard let url = URL(string: "https://172.18.7.103:3000/users/profile") else {
            self.errorMessage = LoginError.invalidURL.localizedDescription
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization") // Include your token

        isLoading = true

        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: User.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                switch completion {
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] user in
                self?.user = user
            })
            .store(in: &cancellables)
    }
}
