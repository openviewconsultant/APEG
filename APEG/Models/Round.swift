import Foundation

struct Round: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let courseName: String
    let courseLocation: String?
    let datePlayed: Date
    let totalScore: Int
    let status: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case courseName = "course_name"
        case courseLocation = "course_location"
        case datePlayed = "date_played"
        case totalScore = "total_score"
        case status
    }
}
