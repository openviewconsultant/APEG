import SwiftUI

struct CourseSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    var onSelect: (GolfCourse) -> Void
    
    let courses = [
        GolfCourse(name: "Country Club de Bogotá", location: "Bogotá, Colombia", distance: "0.5 km", rating: "5.0", imageName: "c1"),
        GolfCourse(name: "Club Los Lagartos", location: "Bogotá, Colombia", distance: "3.2 km", rating: "4.8", imageName: "c2"),
        GolfCourse(name: "Club El Rincón de Cajicá", location: "Cajicá, Colombia", distance: "15.4 km", rating: "4.9", imageName: "c3"),
        GolfCourse(name: "Club Campestre de Medellín", location: "Rionegro, Colombia", distance: "25.1 km", rating: "4.7", imageName: "c4"),
        GolfCourse(name: "Karibana Golf Club", location: "Cartagena, Colombia", distance: "450 km", rating: "4.9", imageName: "c5")
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
                    HStack(spacing: 16) {
                        // Thumbnail
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "flag.fill")
                                    .foregroundColor(.gray.opacity(0.5))
                            )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(course.name)
                                .font(.system(size: 16, weight: .bold))
                            
                            Text(course.location)
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Label(course.distance, systemImage: "location.fill")
                                Spacer()
                                Label(course.rating, systemImage: "star.fill")
                                    .foregroundColor(.orange)
                            }
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.secondary)
                        }
                    }
                }
                .foregroundColor(.primary)
                .padding(.vertical, 8)
                .listRowSeparator(.hidden)
                .listRowBackground(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white)
                        .padding(.vertical, 4)
                        .padding(.horizontal, 16)
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                )
            }
            .listStyle(.plain)
            .navigationTitle("Seleccionar Campo")
            .navigationBarTitleDisplayMode(.inline)
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
