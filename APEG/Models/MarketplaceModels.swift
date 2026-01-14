import Foundation

struct Chat: Identifiable, Codable {
    let id: UUID
    let productId: UUID?
    let buyerId: UUID?
    let sellerId: UUID?
    let createdAt: Date
    
    // Optional: Include Product info if joined
    let product: Product?
    
    enum CodingKeys: String, CodingKey {
        case id
        case productId = "product_id"
        case buyerId = "buyer_id"
        case sellerId = "seller_id"
        case createdAt = "created_at"
        case product
    }
}

struct Message: Identifiable, Codable {
    let id: UUID
    let chatId: UUID
    let senderId: UUID
    let content: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case chatId = "chat_id"
        case senderId = "sender_id"
        case content
        case createdAt = "created_at"
    }
}

struct Review: Identifiable, Codable {
    let id: UUID
    let productId: UUID
    let reviewerId: UUID
    let rating: Int
    let comment: String?
    let createdAt: Date
    
    // Optional: Include Reviewer Profile Name
    let reviewerName: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case productId = "product_id"
        case reviewerId = "reviewer_id"
        case rating
        case comment
        case createdAt = "created_at"
        case reviewerName = "reviewer_name" // This would likely come from a joined query
    }
}
