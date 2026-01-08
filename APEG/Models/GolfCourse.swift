import Foundation

struct GolfCourse: Identifiable, Hashable {
    var id: String { name }
    let name: String
    let location: String
    let distance: String
    let rating: String
    let imageName: String
}
