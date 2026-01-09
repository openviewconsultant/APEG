import SwiftUI
import CoreLocation

struct ActiveRoundView: View {
    let course: GolfCourse
    @Environment(\.dismiss) var dismiss
    @StateObject private var locationManager = LocationManager()
    @State private var currentHole = 1
    @State private var scores: [Int: Int] = [:]
    
    // Generate dummy hole coordinates relative to course center
    // In a real app, this would come from a database API
    private var holeCoordinates: [CLLocationCoordinate2D] {
        (0..<18).map { i in
            // Spiral pattern or random offsets to simulate different hole locations
            let offsetLat = Double(i) * 0.002 * (i % 2 == 0 ? 1 : -1)
            let offsetLon = Double(i) * 0.002 * (i % 3 == 0 ? 1 : -1)
            return CLLocationCoordinate2D(
                latitude: course.coordinate.latitude + offsetLat,
                longitude: course.coordinate.longitude + offsetLon
            )
        }
    }
    
    private var currentHoleLocation: CLLocationCoordinate2D {
        if currentHole <= holeCoordinates.count {
            return holeCoordinates[currentHole - 1]
        }
        return course.coordinate
    }
    
    private var distances: (center: String, back: String, front: String) {
        guard let userLoc = locationManager.location else {
            return ("--", "--", "--")
        }
        
        let holeLoc = CLLocation(latitude: currentHoleLocation.latitude, longitude: currentHoleLocation.longitude)
        let distanceInMeters = userLoc.distance(from: holeLoc)
        let yards = Int(distanceInMeters * 1.09361)
        
        return (
            "\(yards)",
            "\(yards + 15)", // Simulated Back (usually +10-20 yards)
            "\(max(0, yards - 15))" // Simulated Front
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
                Spacer()
                VStack(spacing: 2) {
                    Text(course.name.uppercased())
                        .font(.system(size: 10))
                        .fontWeight(.bold)
                        .foregroundColor(Theme.primary)
                    Text("En Juego")
                        .font(.system(size: 14))
                        .fontWeight(.bold)
                    
                    if !locationManager.isAuthorized {
                        Text("Activar GPS en Ajustes")
                            .font(.caption2)
                            .foregroundColor(.red)
                    }
                }
                Spacer()
                Button("Terminar") { dismiss() }
                    .font(.system(size: 14))
                    .fontWeight(.bold)
                    .foregroundColor(Theme.primary)
            }
            .padding()
            .background(Color.white)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Hole Info & GPS Card
                    VStack(spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("HOYO \(currentHole)")
                                    .font(.system(size: 14))
                                    .fontWeight(.black)
                                Text("Par 4 • Hcp 5")
                                    .font(.system(size: 12))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                            Spacer()
                            Text("\(distances.center) yd")
                                .font(.system(size: 20))
                                .fontWeight(.bold)
                        }
                        
                        Divider().background(Color.white.opacity(0.3))
                        
                        // GPS Distance Display
                        HStack(alignment: .bottom) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("AL CENTRO")
                                    .font(.system(size: 10))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white.opacity(0.7))
                                Text(distances.center)
                                    .font(.system(size: 72))
                                    .fontWeight(.black)
                                    .italic()
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 12) {
                                GPSDistItem(label: "ATRÁS", value: distances.back)
                                GPSDistItem(label: "FRENTE", value: distances.front)
                            }
                        }
                    }
                    .padding(24)
                    .background(Theme.primary)
                    .foregroundColor(.white)
                    .cornerRadius(32)
                    .shadow(color: Theme.primary.opacity(0.3), radius: 15, x: 0, y: 10)
                    .padding(.horizontal)
                    
                    // Score Input Section
                    VStack(spacing: 20) {
                        Text("REGISTRAR SCORE")
                            .font(.system(size: 12))
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 30) {
                            ScoreButton(icon: "minus") { updateScore(-1) }
                            
                            VStack(spacing: 4) {
                                Text("\(scores[currentHole] ?? 4)")
                                    .font(.system(size: 60))
                                    .fontWeight(.black)
                                    .foregroundColor(.primary)
                                Text(scoreLabel)
                                    .font(.system(size: 12))
                                    .fontWeight(.bold)
                                    .foregroundColor(scoreColor)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 4)
                                    .background(scoreColor.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .frame(width: 100)
                            
                            ScoreButton(icon: "plus") { updateScore(1) }
                        }
                    }
                    .padding(.vertical, 20)
                    
                    // Hole Selection (Bottom)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("SIGUIENTE HOYO")
                            .font(.system(size: 12))
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(1...18, id: \.self) { hole in
                                    Button(action: { currentHole = hole }) {
                                        Text("\(hole)")
                                            .font(.system(size: 16))
                                            .fontWeight(.bold)
                                            .frame(width: 50, height: 50)
                                            .background(currentHole == hole ? Theme.primary : Color.white)
                                            .foregroundColor(currentHole == hole ? .white : .primary)
                                            .cornerRadius(15)
                                            .shadow(color: .black.opacity(0.05), radius: 5)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
        }
        .background(Color(hex: "F8F9FA").ignoresSafeArea())
    }
    
    private var scoreLabel: String {
        let s = scores[currentHole] ?? 4
        if s == 4 { return "PAR" }
        if s == 3 { return "BIRDIE" }
        if s == 2 { return "EAGLE" }
        if s == 5 { return "BOGEY" }
        return "\(s - 4 > 0 ? "+" : "")\(s - 4)"
    }
    
    private var scoreColor: Color {
        let s = scores[currentHole] ?? 4
        if s < 4 { return .blue }
        if s > 4 { return .orange }
        return .green
    }
    
    private func updateScore(_ delta: Int) {
        let current = scores[currentHole] ?? 4
        scores[currentHole] = max(1, current + delta)
    }
}

struct GPSDistItem: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(label)
                .font(.system(size: 10))
                .fontWeight(.bold)
                .foregroundColor(.white.opacity(0.6))
            Text(value)
                .font(.system(size: 20))
                .fontWeight(.bold)
        }
    }
}

struct ScoreButton: View {
    let icon: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .frame(width: 60, height: 60)
                .background(Color.white)
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.05), radius: 10)
        }
    }
}

#Preview {
    ActiveRoundView(course: GolfCourse(name: "Country Club de Bogotá", location: "Bogotá", distance: "0km", rating: "5.0", imageName: "", latitude: 4.707, longitude: -74.04))
}
