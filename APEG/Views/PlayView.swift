import SwiftUI

struct PlayView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    @State private var selectedCourse: GolfCourse?
    
    static let courses = GolfCourse.sampleCourses
    
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
                    GolfCourseCard(course: course)
                    }
                    .foregroundColor(.primary)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                    .padding(.vertical, 4)
                }
                .listStyle(.plain)
            }
            .background(Theme.background.ignoresSafeArea())
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
