import Foundation

struct Product: Codable, Identifiable {
    let id: UUID
    let name: String
    let brand: String?
    let description: String?
    let price: Double
    let category: String?
    let imageUrl: String?
    let stockQuantity: Int?
    let sellerId: UUID?
    let images: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case brand
        case description
        case price
        case category
        case imageUrl = "image_url"
        case stockQuantity = "stock_quantity"
        case sellerId = "seller_id"
        case images
    }
}
