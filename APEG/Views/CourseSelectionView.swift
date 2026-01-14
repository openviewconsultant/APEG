import SwiftUI

struct CourseSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    var onSelect: (GolfCourse) -> Void
    
    let courses = [
        GolfCourse(name: "Country Club de Bogotá", location: "Bogotá, Colombia", distance: "0.5 km", rating: "5.0", imageName: "club_bogota", latitude: 4.707, longitude: -74.04, description: "Campo tradicional con altos eucaliptos y fairways estrechos que exigen precisión.", subCourses: ["Fundadores", "Pacos y Fabios"]),
        GolfCourse(name: "Club Los Lagartos", location: "Bogotá, Colombia", distance: "3.2 km", rating: "4.8", imageName: "club_lagartos", latitude: 4.72, longitude: -74.08, description: "Hermoso paisaje con lagos y sauces que entran en juego en varios hoyos.", subCourses: ["Corea", "David Gutiérrez"]),
        GolfCourse(name: "Club El Rincón de Cajicá", location: "Cajicá, Colombia", distance: "15.4 km", rating: "4.9", imageName: "club_rincon", latitude: 4.93, longitude: -74.03, description: "Diseño de Robert Trent Jones, estilo Heathland con vistas a las montañas.", subCourses: nil),
        GolfCourse(name: "Club Campestre de Medellín", location: "Rionegro, Colombia", distance: "25.1 km", rating: "4.7", imageName: "club_medellin", latitude: 6.15, longitude: -75.42, description: "Campo en Llanogrande rodeado de pinos y naturaleza exuberante.", subCourses: ["Sede Llanogrande"]),
        GolfCourse(name: "Karibana Golf Club", location: "Cartagena, Colombia", distance: "450 km", rating: "4.9", imageName: "club_karibana", latitude: 10.57, longitude: -75.50, description: "Único campo TPC en Sudamérica, con espectaculares hoyos frente al mar Caribe.", subCourses: ["Nicklaus Design"])
    ]
    
    var filteredCourses: [GolfCourse] {
        if searchText.isEmpty {
            return courses
        } else {
            return courses.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            List(filteredCourses) { course in
                Button(action: {
                    onSelect(course)
                    dismiss()
                }) {
                    ZStack(alignment: .bottomLeading) {
                        // Background Image
                        Image(course.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 180)
                            .clipped()
                            .overlay(
                                LinearGradient(
                                    gradient: Gradient(colors: [.black.opacity(0.8), .black.opacity(0.2), .clear]),
                                    startPoint: .bottom,
                                    endPoint: .top
                                )
                            )
                        
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Text(course.name)
                                    .font(Theme.Typography.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                HStack(spacing: 4) {
                                    Image(systemName: "star.fill")
                                        .foregroundColor(.orange)
                                        .font(.caption)
                                    Text(course.rating)
                                        .font(.caption)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(BlurView(style: .systemUltraThinMaterialDark))
                                .cornerRadius(8)
                            }
                            
                            if let description = course.description {
                                Text(description)
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.9))
                                    .lineLimit(2)
                            }
                            
                            if let subCourses = course.subCourses {
                                HStack(spacing: 6) {
                                    ForEach(subCourses, id: \.self) { sub in
                                        Text(sub)
                                            .font(.system(size: 10, weight: .bold))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 3)
                                            .background(Color.white.opacity(0.2))
                                            .cornerRadius(4)
                                            .foregroundColor(.white)
                                    }
                                }
                                .padding(.top, 4)
                            }
                            
                            HStack {
                                Label(course.location, systemImage: "map.fill")
                                Spacer()
                                Label(course.distance, systemImage: "location.fill")
                            }
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.top, 4)
                        }
                        .padding(16)
                    }
                    .background(Theme.cardBackground)
                    .cornerRadius(20)
                    .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                }
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .padding(.vertical, 6)
            }
            .listStyle(.plain)
            .navigationTitle("Seleccionar Campo")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Buscar campo o club")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Listo") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                    .foregroundColor(Theme.primary)
                }
            }
        }
    }
}

#Preview {
    CourseSelectionView(onSelect: { _ in })
}
