import SwiftUI

struct CourseSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    var onSelect: (GolfCourse) -> Void
    
    let courses = GolfCourse.sampleCourses
    
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
                    GolfCourseCard(course: course)
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
