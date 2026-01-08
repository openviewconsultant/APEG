import SwiftUI

struct PlayView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var selectedCourse: GolfCourse?
    
    static let courses = [
        GolfCourse(name: "Country Club de Bogotá", location: "Bogotá, Colombia", distance: "0.5 km", rating: "5.0", imageName: "c1"),
        GolfCourse(name: "Club Los Lagartos", location: "Bogotá, Colombia", distance: "3.2 km", rating: "4.8", imageName: "c2"),
        GolfCourse(name: "Club El Rincón de Cajicá", location: "Cajicá, Colombia", distance: "15.4 km", rating: "4.9", imageName: "c3"),
        GolfCourse(name: "Club Campestre de Medellín", location: "Rionegro, Colombia", distance: "25.1 km", rating: "4.7", imageName: "c4"),
        GolfCourse(name: "Karibana Golf Club", location: "Cartagena, Colombia", distance: "450 km", rating: "4.9", imageName: "c5")
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
                                Text(course.location)
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                HStack {
                                    Label(course.distance, systemImage: "location.fill")
                                    Spacer()
                                    Label(course.rating, systemImage: "star.fill")
                                        .foregroundColor(.orange)
                                }
                                .font(.system(size: 12))
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            }
                        }
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
