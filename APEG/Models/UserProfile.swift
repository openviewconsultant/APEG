import Foundation

struct UserProfile: Codable, Identifiable {
    let id: UUID
    let fullName: String?
    let federationCode: String?
    let idPhotoUrl: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case fullName = "full_name"
        case federationCode = "federation_code"
        case idPhotoUrl = "id_photo_url"
        case updatedAt = "updated_at"
    }
}
