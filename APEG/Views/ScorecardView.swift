import SwiftUI

struct HoleScore: Identifiable {
    let id = UUID()
    let number: Int
    let par: Int
    var score: Int?
}

struct ScorecardView: View {
    let courseName: String
    @Environment(\.dismiss) var dismiss
    @State private var currentHoleIndex = 0
    @State private var holes: [HoleScore] = (1...18).map { HoleScore(number: $0, par: [4, 4, 3, 5, 4, 4, 3, 4, 5, 4, 4, 3, 5, 4, 4, 3, 4, 5][$0-1], score: nil) }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    Text("Scorecard")
                        .font(.headline)
                    Spacer()
                    Button("Finalizar") {
                        dismiss()
                    }
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(Theme.primary)
                }
                .padding(.horizontal)
                
                VStack(spacing: 4) {
                    Text(courseName)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text("Hoyo \(holes[currentHoleIndex].number) • Par \(holes[currentHoleIndex].par)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 24)
            .background(Color.white)
            
            // Hole Navigation
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(0..<18) { index in
                        Button(action: { currentHoleIndex = index }) {
                            VStack(spacing: 4) {
                                Text("\(index + 1)")
                                    .font(.system(size: 14, weight: .bold))
                                Circle()
                                    .fill(holes[index].score != nil ? Theme.primary : Color.clear)
                                    .frame(width: 4, height: 4)
                            }
                            .frame(width: 44, height: 44)
                            .background(currentHoleIndex == index ? Theme.primary.opacity(0.1) : Color.gray.opacity(0.05))
                            .foregroundColor(currentHoleIndex == index ? Theme.primary : .primary)
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 32)
            
            // Score Input
            VStack(spacing: 40) {
                Text("\(holes[currentHoleIndex].score ?? holes[currentHoleIndex].par)")
                    .font(.system(size: 80, weight: .black))
                    .foregroundColor(Theme.primary)
                
                HStack(spacing: 40) {
                    Button(action: { updateScore(delta: -1) }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 64, height: 64)
                            .shadow(color: .black.opacity(0.1), radius: 10)
                            .overlay(Image(systemName: "minus").font(.title2).fontWeight(.bold))
                    }
                    
                    Button(action: { updateScore(delta: 1) }) {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 64, height: 64)
                            .shadow(color: .black.opacity(0.1), radius: 10)
                            .overlay(Image(systemName: "plus").font(.title2).fontWeight(.bold))
                    }
                }
                .foregroundColor(.primary)
            }
            .frame(maxHeight: .infinity)
            
            // Stats Row
            HStack(spacing: 24) {
                StatView(label: "TOTAL", value: "\(totalScore)")
                StatView(label: "TO PAR", value: "\(toPar > 0 ? "+" : "")\(toPar)")
                StatView(label: "HOYOS", value: "\(playedHoles)/18")
            }
            .padding(24)
            .background(Color.white)
            .cornerRadius(32, corners: [.topLeft, .topRight])
            .shadow(color: .black.opacity(0.05), radius: 15)
        }
        .background(Color(hex: "F8F9FA").ignoresSafeArea())
    }
    
    private var totalScore: Int {
        holes.compactMap { $0.score }.reduce(0, +)
    }
    
    private var toPar: Int {
        holes.filter { $0.score != nil }.map { ($0.score ?? 0) - $0.par }.reduce(0, +)
    }
    
    private var playedHoles: Int {
        holes.filter { $0.score != nil }.count
    }
    
    private func updateScore(delta: Int) {
        let currentScore = holes[currentHoleIndex].score ?? holes[currentHoleIndex].par
        holes[currentHoleIndex].score = max(1, currentScore + delta)
    }
}

struct StatView: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
            Text(value)
                .font(.system(size: 18, weight: .bold))
        }
        .frame(maxWidth: .infinity)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    ScorecardView(courseName: "Country Club de Bogotá")
}
