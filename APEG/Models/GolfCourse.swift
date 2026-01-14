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
    let description: String?
    let subCourses: [String]?
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    static let sampleCourses = [
        GolfCourse(
            name: "Country Club de Bogotá",
            location: "Bogotá, Colombia",
            distance: "0.5 km",
            rating: "5.0",
            imageName: "club_bogota",
            latitude: 4.707,
            longitude: -74.04,
            description: "Campo tradicional con altos eucaliptos y fairways estrechos que exigen precisión.",
            subCourses: ["Fundadores", "Pacos y Fabios"]
        ),
        GolfCourse(
            name: "Club Los Lagartos",
            location: "Bogotá, Colombia",
            distance: "3.2 km",
            rating: "4.8",
            imageName: "club_lagartos",
            latitude: 4.72,
            longitude: -74.08,
            description: "Hermoso paisaje con lagos y sauces que entran en juego en varios hoyos.",
            subCourses: ["Corea", "David Gutiérrez"]
        ),
        GolfCourse(
            name: "Club El Rincón de Cajicá",
            location: "Cajicá, Colombia",
            distance: "15.4 km",
            rating: "4.9",
            imageName: "club_rincon",
            latitude: 4.93,
            longitude: -74.03,
            description: "Diseño de Robert Trent Jones, estilo Heathland con vistas a las montañas.",
            subCourses: ["Campo Principal"]
        ),
        GolfCourse(
            name: "Club Campestre de Medellín",
            location: "Rionegro, Colombia",
            distance: "25.1 km",
            rating: "4.7",
            imageName: "club_medellin",
            latitude: 6.15,
            longitude: -75.42,
            description: "Campo en Llanogrande rodeado de pinos y naturaleza exuberante.",
            subCourses: ["Sede Llanogrande"]
        ),
        GolfCourse(
            name: "Karibana Golf Club",
            location: "Cartagena, Colombia",
            distance: "450 km",
            rating: "4.9",
            imageName: "club_karibana",
            latitude: 10.57,
            longitude: -75.50,
            description: "Único campo TPC en Sudamérica, con espectaculares hoyos frente al mar Caribe.",
            subCourses: ["Nicklaus Design"]
        )
    ]
}
