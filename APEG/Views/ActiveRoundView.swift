import SwiftUI
import CoreLocation
import MapKit

struct ActiveRoundView: View {
    let course: GolfCourse
    @Environment(\.dismiss) var dismiss
    @StateObject private var locationManager = LocationManager()
    @State private var currentHole = 1
    @State private var scores: [Int: Int] = [:]
    @State private var isSaving = false
    
    // Alert state
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    
    // Camera position for MapKit
    @State private var position: MapCameraPosition = .automatic
    
    // Generate dummy hole coordinates relative to course center
    private var holeCoordinates: [CLLocationCoordinate2D] {
        (0..<18).map { i in
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
            "\(yards + 15)",
            "\(max(0, yards - 15))"
        )
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Updated Header
            HStack {
                Button(action: { dismiss() }) {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 40, height: 40)
                        .overlay(Image(systemName: "xmark").foregroundColor(.primary))
                }
                Spacer()
                VStack(spacing: 4) {
                    Text(course.name.uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .tracking(1)
                        .foregroundColor(Theme.primary)
                    HStack(spacing: 6) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                            .shadow(color: .green.opacity(0.5), radius: 4)
                        Text("En Juego")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    
                    if !locationManager.isAuthorized {
                        Text("Activar GPS en Ajustes")
                            .font(.caption2)
                            .foregroundColor(.red)
                            .padding(.top, 2)
                    }
                }
                Spacer()
                
                if isSaving {
                    ProgressView()
                } else {
                    Button(action: finishRound) {
                        Text("Terminar")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Theme.primary)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Theme.primary.opacity(0.1))
                            .cornerRadius(20)
                    }
                }
            }
            .padding(.horizontal, 25)
            .padding(.vertical, 16)
            .background(Color.white)
            .shadow(color: Color.black.opacity(0.03), radius: 10, x: 0, y: 5)
            .zIndex(10)
            
            ScrollView {
                VStack(spacing: 30) {
                    
                    // Compact GPS Card
                    ZStack {
// ... existing gradient/circles ...
                        HStack(spacing: 0) {
                            // Left Side: Info & Main Distance
                            VStack(alignment: .leading, spacing: 12) {
                                // Header
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                                        Text("HOYO")
                                            .font(Theme.Typography.headline)
                                            .foregroundColor(.white.opacity(0.8))
                                        Text("\(currentHole)")
                                            .font(Theme.Typography.title1)
                                            .foregroundColor(.white)
                                    }
                                    Text("Par 4 • Hcp 5")
                                        .font(Theme.Typography.caption)
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(Color.black.opacity(0.25))
                                        .cornerRadius(8)
                                }
                                
                                Spacer()
                                
                                // Main Distance
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("AL CENTRO")
                                        .font(Theme.Typography.headline)
                                        .tracking(1.2)
                                        .foregroundColor(Color.white.opacity(0.7))
                                    
                                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                                        Text(distances.center)
                                            .font(.system(size: 64, weight: .black))
                                            .foregroundColor(.white)
                                        Text("yd")
                                            .font(.system(size: 22, weight: .black))
                                            .foregroundColor(.white.opacity(0.8))
                                    }
                                }
                            }
                            .padding(24)
                            
                            Spacer()
                            
                            // Right Side: Mini Map & Other Distances
                            VStack(spacing: 20) {
                                // Mini Map (Drawing / Standard Style)
                                Map(position: $position) {
                                    Marker("", coordinate: currentHoleLocation)
                                        .tint(.green)
                                }
                                .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 18))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                                .shadow(color: .black.opacity(0.2), radius: 8)
                                .onAppear { updateMapRegion() }
                                .onChange(of: currentHole) {
                                    updateMapRegion()
                                }
                                
                                // Back/Front
                                VStack(spacing: 10) {
                                    GPSDistItem(label: "ATRÁS", value: distances.back)
                                    GPSDistItem(label: "FRENTE", value: distances.front)
                                }
                            }
                            .padding(20)
                        }
                    }
                    .frame(height: 260)
                    .mask(RoundedRectangle(cornerRadius: 32))
                    .shadow(color: Theme.primary.opacity(0.3), radius: 20, x: 0, y: 10)
                    .padding(.horizontal, 25)
                    
                    // Score Input Section
                    VStack(spacing: 16) {
                        Text("REGISTRAR SCORE")
                            .font(Theme.Typography.headline)
                            .tracking(1.5)
                            .foregroundColor(.secondary.opacity(0.7))
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 28)
                                .fill(Color.white)
                                .shadow(color: .black.opacity(0.04), radius: 15, x: 0, y: 8)
                            
                            HStack(spacing: 0) {
                                Button(action: { updateScore(-1) }) {
                                    ZStack {
                                        Color.clear
                                        Image(systemName: "minus")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(Theme.primary)
                                    }
                                }
                                .frame(width: 80, height: 100)
                                
                                Divider().frame(height: 60)
                                
                                VStack(spacing: 6) {
                                    Text("\(scores[currentHole] ?? 4)")
                                        .font(.system(size: 56, weight: .black))
                                        .foregroundColor(.primary)
                                    
                                    Text(scoreLabel)
                                        .font(.system(size: 11, weight: .black))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 6)
                                        .background(Capsule().fill(scoreColor))
                                }
                                .frame(maxWidth: .infinity)
                                
                                Divider().frame(height: 60)
                                
                                Button(action: { updateScore(1) }) {
                                    ZStack {
                                        Color.clear
                                        Image(systemName: "plus")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(Theme.primary)
                                    }
                                }
                                .frame(width: 80, height: 100)
                            }
                        }
                        .frame(height: 110)
                        .padding(.horizontal, 25)
                    }
                    
                    // Hole Selection
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Text("SIGUIENTE HOYO")
                                .font(Theme.Typography.headline)
                                .tracking(1.2)
                                .foregroundColor(.secondary.opacity(0.7))
                            Spacer()
                        }
                        .padding(.horizontal, 30)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(1...18, id: \.self) { hole in
                                    Button(action: { 
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            currentHole = hole 
                                        }
                                    }) {
                                        VStack(spacing: 2) {
                                            Text("\(hole)")
                                                .font(.system(size: 16, weight: .bold))
                                            if currentHole == hole {
                                                Circle()
                                                    .fill(Color.white)
                                                    .frame(width: 4, height: 4)
                                            }
                                        }
                                        .frame(width: 50, height: 58)
                                        .background(
                                            RoundedRectangle(cornerRadius: 14)
                                                .fill(currentHole == hole ? Theme.primary : Color.white)
                                                .shadow(
                                                    color: currentHole == hole ? Theme.primary.opacity(0.4) : Color.black.opacity(0.05),
                                                    radius: currentHole == hole ? 6 : 3,
                                                    x: 0,
                                                    y: currentHole == hole ? 3 : 2
                                                )
                                        )
                                        .foregroundColor(currentHole == hole ? .white : .primary)
                                        .scaleEffect(currentHole == hole ? 1.05 : 1.0)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 20)
                        }
                    }
                }
                .padding(.vertical, 20)
            }
        }
        .background(Color(hex: "F8F9FA").ignoresSafeArea())
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertTitle),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if alertTitle == "Guardado" {
                        dismiss()
                    }
                }
            )
        }
    }
    
    private func updateMapRegion() {
        // Center the camera on the hole
        let centerLat = currentHoleLocation.latitude
        let centerLon = currentHoleLocation.longitude
        
        position = .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLon),
            span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
        ))
    }
    
    // Updated finish logic with alert debug
    private func finishRound() {
        guard let userId = SupabaseManager.shared.currentUserId else {
            alertTitle = "Error"
            alertMessage = "No se encontró usuario activo. Intenta iniciar sesión nuevamente."
            showAlert = true
            return
        }
        
        isSaving = true
        
        // Print debug info
        print("Attempting to save round for user: \(userId)")
        print("Course: \(course.name)")
        print("Scores count: \(scores.count)")
        
        SupabaseManager.shared.saveRound(userId: userId, courseName: course.name, scores: scores) { result in
            DispatchQueue.main.async {
                isSaving = false
                switch result {
                case .success:
                    alertTitle = "Guardado"
                    alertMessage = "Tu ronda ha sido guardada exitosamente."
                    showAlert = true
                case .failure(let error):
                    alertTitle = "Error al Guardar"
                    alertMessage = "Detalle: \(error). Verifica tu conexión."
                    showAlert = true
                    print("Detailed Save Error: \(error)")
                }
            }
        }
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
        return Color(hex: "2E8B57")
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
                .font(.system(size: 8, weight: .bold))
                .tracking(0.5)
                .foregroundColor(.white.opacity(0.8))
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(Color.white.opacity(0.15))
        .cornerRadius(8)
    }
}

#Preview {
    ActiveRoundView(course: GolfCourse(name: "Country Club de Bogotá", location: "Bogotá", distance: "0km", rating: "5.0", imageName: "", latitude: 4.707, longitude: -74.04))
}
