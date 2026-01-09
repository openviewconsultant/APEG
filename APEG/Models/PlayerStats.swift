import Foundation

struct PlayerStats: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let handicapIndex: Double
    let totalRounds: Int
    let averageScore: Double
    let bestScore: Int
    
    // Performance
    let fairwaysHitRate: Double
    let girRate: Double
    let averagePutts: Double
    let scramblingRate: Double
    
    // Scoring Breakdown
    let totalEagles: Int
    let totalBirdies: Int
    let totalPars: Int
    let totalBogeys: Int
    let totalDoublesWorse: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case handicapIndex = "handicap_index"
        case totalRounds = "total_rounds"
        case averageScore = "average_score"
        case bestScore = "best_score"
        case fairwaysHitRate = "fairways_hit_rate"
        case girRate = "gir_rate"
        case averagePutts = "average_putts"
        case scramblingRate = "scrambling_rate"
        case totalEagles = "total_eagles"
        case totalBirdies = "total_birdies"
        case totalPars = "total_pars"
        case totalBogeys = "total_bogeys"
        case totalDoublesWorse = "total_doubles_worse"
    }
}
