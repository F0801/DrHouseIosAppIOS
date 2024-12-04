import Foundation

struct Product: Identifiable, Codable {
    var id: String  // This will map to "_id" from the API response
    var name: String
    var description: String
    var price: Double
    var category: String?
    var image: String

    // Use CodingKeys to map the "_id" field from the response to "id" in the model
    enum CodingKeys: String, CodingKey {
        case id = "_id"  // Map "_id" from the JSON to "id" in the model
        case name
        case description
        case price
        case category
        case image
    }
}
