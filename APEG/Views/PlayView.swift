import SwiftUI

struct PlayView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var selectedCourse: GolfCourse?
    
    static let courses = [
        GolfCourse(name: "Country Club de Bogotá", location: "Bogotá, Colombia", distance: "0.5 km", rating: "5.0", imageName: "c1", latitude: 4.707, longitude: -74.04),
        GolfCourse(name: "Club Los Lagartos", location: "Bogotá, Colombia", distance: "3.2 km", rating: "4.8", imageName: "c2", latitude: 4.72, longitude: -74.08),
        GolfCourse(name: "Club El Rincón de Cajicá", location: "Cajicá, Colombia", distance: "15.4 km", rating: "4.9", imageName: "c3", latitude: 4.93, longitude: -74.03),
        GolfCourse(name: "Club Campestre de Medellín", location: "Rionegro, Colombia", distance: "25.1 km", rating: "4.7", imageName: "c4", latitude: 6.15, longitude: -75.42),
        GolfCourse(name: "Karibana Golf Club", location: "Cartagena, Colombia", distance: "450 km", rating: "4.9", imageName: "c5", latitude: 10.57, longitude: -75.50)
    ]
    
    var filteredCourses: [GolfCourse] {
        if searchText.isEmpty {
            return Self.courses
        } else {
            return Self.courses.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // GolfCourse List
                List(filteredCourses) { course in
                    Button(action: {
                        DispatchQueue.main.async {
                            selectedCourse = course
                        }
                    }) {
                        HStack(spacing: 16) {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 70, height: 70)
                                .overlay(Image(systemName: "flag.fill").foregroundColor(Theme.primary.opacity(0.5)))
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(course.name)
                                    .font(.system(size: 16))
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                                Text(course.location)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                HStack {
                                    Label(course.distance, systemImage: "location.fill")
                                    Spacer()
                                    HStack(spacing: 4) {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(.orange)
                                        Text(course.rating)
                                            .foregroundColor(Theme.primary)
                                            .fontWeight(.bold)
                                    }
                                }
                                .font(.system(size: 12))
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 8) // Add internal vertical padding
                        .padding(.horizontal, 4) // Add internal horizontal padding to pull away from edges
                    }
                    .foregroundColor(.primary)
                    .listRowSeparator(.hidden)
                    .listRowBackground(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.white)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 16)
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    )
                }
                .listStyle(.plain)
            }
            .background(Color(hex: "F8F9FA").ignoresSafeArea())
            .navigationTitle("Seleccionar Campo")
            .navigationBarTitleDisplayMode(.large)
            .searchable(text: $searchText, prompt: "Club, ciudad o cercanía")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.gray.opacity(0.5))
                    }
                }
            }
            .fullScreenCover(item: $selectedCourse) { course in
                ActiveRoundView(course: course)
            }
        }
    }
}

#Preview {
    PlayView()
}
