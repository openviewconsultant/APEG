import SwiftUI

struct GameStatsView: View {
    @State private var stats: PlayerStats?
    @State private var isLoading = true
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Main Header Stats
                if isLoading {
                    ProgressView()
                        .padding()
                } else if let stats = stats {
                    HStack(spacing: 16) {
                        StatHighlightCard(title: "Handicap", value: String(format: "%.1f", stats.handicapIndex), color: Theme.primary)
                        StatHighlightCard(title: "Promedio", value: String(format: "%.1f", stats.averageScore), color: .orange)
                        StatHighlightCard(title: "Mejor Ronda", value: "\(stats.bestScore)", color: .blue)
                    }
                    .padding(.horizontal)
                    
                    // Detailed Performance
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Rendimiento")
                            .font(.system(size: 18, weight: .bold))
                            .padding(.horizontal)
                        
                        VStack(spacing: 12) {
                            StatRow(label: "Fairways Acertados (FIR)", value: String(format: "%.1f%%", stats.fairwaysHitRate), icon: "arrow.up.forward.circle.fill", color: .green)
                            StatRow(label: "Greens en Regulación (GIR)", value: String(format: "%.1f%%", stats.girRate), icon: "flag.circle.fill", color: .blue)
                            StatRow(label: "Putts por Ronda", value: String(format: "%.1f", stats.averagePutts), icon: "circle.circle.fill", color: .purple)
                            StatRow(label: "Scrambling", value: String(format: "%.1f%%", stats.scramblingRate), icon: "bolt.circle.fill", color: .orange)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                        .padding(.horizontal)
                    }
                    
                    // Scoring Breakdown
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Desglose de Puntuación")
                            .font(.system(size: 18, weight: .bold))
                            .padding(.horizontal)
                        
                        HStack(spacing: 12) {
                            ScoreCard(label: "Birdies+", value: "\(stats.totalBirdies + stats.totalEagles)", color: .green)
                            ScoreCard(label: "Pars", value: "\(stats.totalPars)", color: .gray)
                            ScoreCard(label: "Bogeys", value: "\(stats.totalBogeys)", color: .orange)
                            ScoreCard(label: "Dobles+", value: "\(stats.totalDoublesWorse)", color: .red)

                        }
                        .padding(.horizontal)
                    }
                    
                    Text("Basado en \(stats.totalRounds) rondas registradas")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.top)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.bar.xaxis")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("No hay estadísticas disponibles")
                            .font(.headline)
                        Text("Juega tu primera ronda para ver tus estadísticas.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 50)
                }
            }
            .padding(.vertical)
        }
        .background(Color(hex: "F8F9FA").ignoresSafeArea())
        .navigationTitle("Estadísticas")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadStats()
        }
    }
    
    private func loadStats() {
        guard let userId = SupabaseManager.shared.currentUserId else { return }
        
        SupabaseManager.shared.fetchPlayerStats(userId: userId) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let data):
                    self.stats = data
                case .failure(let error):
                    print("Error chart: \(error)")
                }
            }
        }
    }
}

struct StatHighlightCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(color)
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct StatRow: View {
    let label: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 24))
            
            Text(label)
                .font(.system(size: 14, weight: .medium))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
        }
    }
}

struct ScoreCard: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(color)
            Text(label)
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
