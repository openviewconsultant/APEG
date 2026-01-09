import SwiftUI
import Foundation

struct GameStatsView: View {
    @State private var stats: PlayerStats?
    @State private var rounds: [Round] = []
    @State private var isLoading = true
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                
                // Header / Title
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.title3)
                            .foregroundColor(.black)
                            .padding(12)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                    
                    Text("Rendimiento")
                        .font(.custom("Outfit-Bold", size: 30))
                        .foregroundColor(Theme.deepBlack)
                    
                    Spacer()
                    
                    Image(systemName: "chart.bar.xaxis")
                        .font(.title3)
                        .foregroundColor(Theme.primary)
                        .padding(12)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
                .padding(.horizontal)
                .padding(.top, 20)
                
                // Main Handicap Circle
                ZStack {
                    Circle()
                        .stroke(Color.white, lineWidth: 20)
                        .shadow(color: .black.opacity(0.03), radius: 10)
                    
                    Circle()
                        .trim(from: 0, to: 0.75)
                        .stroke(
                            LinearGradient(gradient: Gradient(colors: [Theme.primary, Theme.secondary]), startPoint: .topLeading, endPoint: .bottomTrailing),
                            style: StrokeStyle(lineWidth: 18, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                    
                    VStack {
                        Text(estimatedHandicap)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(Theme.deepBlack)
                        Text("HANDICAP")
                            .font(.caption)
                            .fontWeight(.bold)
                            .tracking(2)
                            .foregroundColor(Theme.primary)
                    }
                }
                .frame(width: 180, height: 180)
                .padding(.vertical, 10)
                
                // Quick Stats Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ModernStatCard(title: "Promedio", value: averageScore, icon: "target", color: .orange)
                    ModernStatCard(title: "Mejor Ronda", value: bestScore, icon: "trophy.fill", color: .yellow)
                    ModernStatCard(title: "Rondas", value: "\(rounds.count)", icon: "figure.golf", color: .blue)
                    ModernStatCard(title: "Ranking", value: "#42", icon: "list.number", color: .purple)
                }
                .padding(.horizontal)
                
                // Performance Chart Section
                VStack(alignment: .leading, spacing: 16) {
                    Text("Tendencia de Rondas")
                        .font(.custom("Outfit-Bold", size: 18))
                        .foregroundColor(Theme.deepBlack)
                        .padding(.leading)
                    
                    if rounds.isEmpty {
                        EmptyChartPlaceholder()
                    } else {
                        ScoreTrendChart(rounds: rounds)
                        
                        Text("Análisis de Habilidades")
                            .font(.custom("Outfit-Bold", size: 18))
                            .foregroundColor(Theme.deepBlack)
                            .padding(.leading)
                            .padding(.top, 10)
                            
                        SkillRadarChart()
                    }
                }
                .padding(.vertical)
                
                // Recent Rounds List
                VStack(alignment: .leading, spacing: 16) {
                    Text("Historial Reciente")
                        .font(.custom("Outfit-Bold", size: 18))
                        .foregroundColor(Theme.deepBlack)
                        .padding(.horizontal)
                    
                    if rounds.isEmpty {
                        VStack(spacing: 8) {
                            Image(systemName: "golfball")
                                .font(.largeTitle)
                                .foregroundColor(.gray.opacity(0.3))
                            Text("Sin historial aún")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(40)
                    } else {
                        ForEach(rounds.prefix(5)) { round in
                            ModernRoundRow(round: round)
                        }
                    }
                }
                .padding(.bottom, 120)
            }
        }
        .background(Theme.background.ignoresSafeArea())
        .navigationBarHidden(true)
        .onAppear {
            loadData()
        }
    }
    
    private var averageScore: String {
        guard !rounds.isEmpty else { return "--" }
        let total = rounds.reduce(0) { $0 + $1.totalScore }
        return String(format: "%.1f", Double(total) / Double(rounds.count))
    }
    
    private var bestScore: String {
        guard let min = rounds.map({ $0.totalScore }).min() else { return "--" }
        return "\(min)"
    }
    
    private var estimatedHandicap: String {
        guard !rounds.isEmpty else { return "54.0" }
        let avg = Double(rounds.reduce(0) { $0 + $1.totalScore }) / Double(rounds.count)
        let diff = max(0, avg - 72)
        return String(format: "%.1f", diff * 0.8)
    }
    
    private func loadData() {
        guard let userId = SupabaseManager.shared.currentUserId else { return }
        SupabaseManager.shared.fetchRounds(userId: userId) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                if case .success(let fetchedRounds) = result {
                    self.rounds = fetchedRounds
                }
            }
        }
    }
}

// MARK: - Subviews

struct ModernStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.headline)
                    .padding(8)
                    .background(color.opacity(0.1))
                    .clipShape(Circle())
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Theme.deepBlack)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
    }
}

struct EmptyChartPlaceholder: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.largeTitle)
                .foregroundColor(.gray.opacity(0.3))
            Text("No hay datos suficientes")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(20)
        .padding(.horizontal)
        .shadow(color: .black.opacity(0.03), radius: 5)
    }
}

struct ScoreTrendChart: View {
    let rounds: [Round]
    
    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let recent = Array(rounds.prefix(10).reversed())
            
            if !recent.isEmpty {
                let scores = recent.map { CGFloat($0.totalScore) }
                let minS = (scores.min() ?? 72) - 5
                let maxS = (scores.max() ?? 100) + 5
                let range = max(1, maxS - minS)
                
                Path { path in
                    for (index, score) in scores.enumerated() {
                        let x = width * CGFloat(index) / CGFloat(max(scores.count - 1, 1))
                        let y = height - ((score - minS) / range) * height
                        if index == 0 { path.move(to: CGPoint(x: x, y: y)) }
                        else { path.addLine(to: CGPoint(x: x, y: y)) }
                    }
                }
                .stroke(
                    LinearGradient(gradient: Gradient(colors: [Theme.primary, Theme.secondary]), startPoint: .leading, endPoint: .trailing),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                )
                
                Path { path in
                    for (index, score) in scores.enumerated() {
                        let x = width * CGFloat(index) / CGFloat(max(scores.count - 1, 1))
                        let y = height - ((score - minS) / range) * height
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: height))
                            path.addLine(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                        if index == scores.count - 1 { path.addLine(to: CGPoint(x: x, y: height)) }
                    }
                    path.closeSubpath()
                }
                .fill(LinearGradient(gradient: Gradient(colors: [Theme.primary.opacity(0.15), Theme.primary.opacity(0.0)]), startPoint: .top, endPoint: .bottom))
            }
        }
        .frame(height: 180)
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
        .padding(.horizontal)
    }
}

struct SkillRadarChart: View {
    let stats: [Double] = [0.8, 0.6, 0.9, 0.7, 0.5]
    
    var body: some View {
        ZStack {
            ForEach([0.2, 0.4, 0.6, 0.8, 1.0], id: \.self) { r in
                PolygonShape(sides: 5, radius: 90 * r)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
            }
            
            PolygonShape(sides: 5, radius: 90, values: stats)
                .fill(Theme.primary.opacity(0.2))
                .overlay(PolygonShape(sides: 5, radius: 90, values: stats).stroke(Theme.primary, lineWidth: 2))
            
            VStack {
                Text("Longitud").font(.system(size: 10, weight: .bold)).foregroundColor(.secondary).offset(y: -105)
                HStack {
                   Text("Mental").font(.system(size: 10, weight: .bold)).foregroundColor(.secondary).offset(x: -110)
                   Spacer()
                   Text("Puntería").font(.system(size: 10, weight: .bold)).foregroundColor(.secondary).offset(x: 110)
                }
                HStack {
                   Text("Putting").font(.system(size: 10, weight: .bold)).foregroundColor(.secondary).offset(x: -80, y: 70)
                   Spacer()
                   Text("Recovery").font(.system(size: 10, weight: .bold)).foregroundColor(.secondary).offset(x: 80, y: 70)
                }
            }
            .frame(width: 200, height: 200)
        }
        .frame(height: 260)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(24)
        .shadow(color: .black.opacity(0.04), radius: 10, x: 0, y: 4)
        .padding(.horizontal)
    }
}

struct PolygonShape: Shape {
    var sides: Int
    var radius: CGFloat
    var values: [Double]? = nil
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let angle = 2.0 * .pi / Double(sides)
        for i in 0..<sides {
            let r = values != nil ? radius * (values![i]) : radius
            let x = center.x + r * cos(Double(i) * angle - .pi / 2)
            let y = center.y + r * sin(Double(i) * angle - .pi / 2)
            if i == 0 { path.move(to: CGPoint(x: x, y: y)) }
            else { path.addLine(to: CGPoint(x: x, y: y)) }
        }
        path.closeSubpath()
        return path
    }
}

struct ModernRoundRow: View {
    let round: Round
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(round.courseName)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(Theme.deepBlack)
                Text(dateFormatter.string(from: round.datePlayed))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            
            Text("\(round.totalScore)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(scoreColor(score: round.totalScore))
                .frame(width: 44, height: 44)
                .background(scoreColor(score: round.totalScore).opacity(0.1))
                .clipShape(Circle())
        }
        .padding()
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.04), radius: 8, x: 0, y: 3)
        .padding(.horizontal)
    }
    
    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .medium
        return f
    }()
    
    private func scoreColor(score: Int) -> Color {
        if score < 72 { return .blue }
        if score < 80 { return Theme.primary }
        return .orange
    }
}
