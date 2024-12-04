import Foundation

struct OCRResponse: Decodable {
    let statusCode: Int
    let text: String?
    let message: String?
}

class OCRService {
    static func uploadImage(imageData: Data, completion: @escaping (Result<String, Error>) -> Void) {
        guard let url = URL(string: "http://192.168.137.159:3000/ocr/upload") else {
            completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        var body: [String: Any] = [:]
        body["file"] = imageData.base64EncodedString()
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let json = try JSONDecoder().decode(OCRResponse.self, from: data)

                if json.statusCode == 200, let text = json.text {
                    completion(.success(text))
                } else {
                    completion(.failure(NSError(domain: "", code: json.statusCode, userInfo: [NSLocalizedDescriptionKey: json.message ?? "Unknown error"])))
                }
            } catch {
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
