import Alamofire
import Foundation

class ProductRepository {
    private let baseURL = "http://192.168.39.48:3000/" // Replace with your backend API base URL

    // Fetch all products
    func fetchProducts(completion: @escaping (Result<[Product], Error>) -> Void) {
        let url = baseURL + "product" // Your endpoint for fetching all products
        
        AF.request(url, method: .get)
            .response { response in
                if let data = response.data {
                    // Log the raw response data for debugging
                    if let stringResponse = String(data: data, encoding: .utf8) {
                        print("Raw Response: \(stringResponse)")
                    }
                }
                
                // Decode the response data into an array of Product objects
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        // Ensure key decoding strategy is set to convert _id to id
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let products = try decoder.decode([Product].self, from: data!)
                        completion(.success(products))
                    } catch let decodingError {
                        print("Decoding error: \(decodingError)")
                        completion(.failure(decodingError))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    
    // Fetch products by category
    func fetchProductsByCategory(byCategory category: String, completion: @escaping (Result<[Product], Error>) -> Void) {
        let url = baseURL + "product/category/\(category)" // Your endpoint for fetching products by category
        
        AF.request(url, method: .get)
            .response { response in
                if let data = response.data {
                    // Log the raw response data for debugging
                    if let stringResponse = String(data: data, encoding: .utf8) {
                        print("Raw Response: \(stringResponse)")
                    }
                }

                // Decode the response data into an array of Product objects
                switch response.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        // Ensure key decoding strategy is set to convert _id to id
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let products = try decoder.decode([Product].self, from: data!)
                        completion(.success(products))
                    } catch let decodingError {
                        print("Decoding error: \(decodingError)")
                        completion(.failure(decodingError))
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
