import Foundation
import CoreLocation

struct GolfCourse: Identifiable, Hashable {
    var id: String { name }
    let name: String
    let location: String
    let distance: String
    let rating: String
    let imageName: String
    let latitude: Double
    let longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
