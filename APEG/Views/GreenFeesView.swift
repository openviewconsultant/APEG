import SwiftUI

struct GreenFeesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Reservar Green Fee")
                    .font(Theme.Typography.largeTitle)
                    .foregroundColor(.white)
                    .padding(.horizontal, 25)
                
                VStack(spacing: 25) {
                    // Quick Search Component
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.gray)
                        Text("¿Dónde quieres jugar?")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(18)
                    .background(ModernCardBackground())
                    .padding(.horizontal, 25)
                    
                    // Filter Chips
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            FilterChip(title: "Cerca de mí", icon: "location.fill", isSelected: true)
                            FilterChip(title: "Top Rated", icon: "star.fill", isSelected: false)
                            FilterChip(title: "Ofertas", icon: "tag.fill", isSelected: false)
                        }
                        .padding(.horizontal, 25)
                    }
                    
                    // Featured Courses
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Campos Recomendados")
                            .font(Theme.Typography.title3)
                            .foregroundColor(.white)
                            .padding(.horizontal, 25)
                        
                        ForEach(0..<3) { _ in
                            CourseCard()
                                .padding(.horizontal, 22)
                        }
                    }
                }
            }
            .padding(.vertical, 10)
            .padding(.bottom, 120)
        }
        .background(Theme.background.ignoresSafeArea())
    }
}

struct FilterChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(title)
        }
        .font(.system(size: 14, weight: .bold))
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(isSelected ? Theme.primary : Theme.cardBackground)
        .foregroundColor(.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct CourseCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 180)
                
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.orange)
                    Text("4.8")
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Theme.cardBackground)
                .cornerRadius(12)
                .padding(12)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Pebble Beach Golf Links")
                    .font(Theme.Typography.body)
                    .foregroundColor(.white)
                
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                    Text("San Francisco, CA")
                    Spacer()
                    Text("desde $250")
                        .font(Theme.Typography.body)
                        .foregroundColor(Theme.primary)
                }
                .font(Theme.Typography.caption)
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
        }
        .padding(12)
        .background(ModernCardBackground())
    }
}

#Preview {
    GreenFeesView()
}
