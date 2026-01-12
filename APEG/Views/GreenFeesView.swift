import SwiftUI

struct GreenFeesView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Reservar Green Fee")
                    .font(Theme.Typography.largeTitle)
                    .foregroundColor(Color(hex: "1A1A1A"))
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
                    .background(Color.white)
                    .cornerRadius(18)
                    .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 5)
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
                            .font(.system(size: 20, weight: .black))
                            .foregroundColor(Color(hex: "1A1A1A"))
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
        .background(Color(hex: "F8F9FA").ignoresSafeArea())
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
        .background(isSelected ? Theme.primary : Color.white)
        .foregroundColor(isSelected ? .white : .black)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
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
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white)
                .cornerRadius(12)
                .padding(12)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Pebble Beach Golf Links")
                    .font(.system(size: 18, weight: .bold))
                
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                    Text("San Francisco, CA")
                    Spacer()
                    Text("desde $250")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(Theme.primary)
                }
                .font(.system(size: 14))
                .foregroundColor(.secondary)
            }
            .padding(.horizontal, 8)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(32)
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    GreenFeesView()
}
