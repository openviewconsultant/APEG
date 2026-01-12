import SwiftUI

struct TournamentsView: View {
    @State private var selectedFilter = "Todos"
    let filters = ["Todos", "Pro", "Amateur", "Caridad"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Torneos")
                            .font(Theme.Typography.largeTitle)
                            .foregroundColor(Color(hex: "1A1A1A"))
                        Spacer()
                        Button(action: {}) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.black)
                                .padding(12)
                                .background(Color.white)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 5)
                        }
                    }
                    .padding(.horizontal, 25)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(filters, id: \.self) { filter in
                                Button(action: {
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                    selectedFilter = filter 
                                }) {
                                    Text(filter)
                                        .font(Theme.Typography.button)
                                        .padding(.horizontal, 28)
                                        .padding(.vertical, 14)
                                        .background(selectedFilter == filter ? Theme.primary : Color.white)
                                        .foregroundColor(selectedFilter == filter ? .white : .black.opacity(0.6))
                                        .cornerRadius(18)
                                        .shadow(color: selectedFilter == filter ? Theme.primary.opacity(0.3) : .black.opacity(0.03), radius: 10, x: 0, y: 5)
                                }
                            }
                        }
                        .padding(.horizontal, 25)
                    }
                }
                
                VStack(spacing: 25) {
                    TournamentCard(
                        title: "The Coastal Open",
                        location: "Pebble Beach Golf Links",
                        date: "OCT 12-14",
                        fee: 450,
                        isFeatured: true
                    )
                    
                    TournamentCard(
                        title: "Masters Qualifier",
                        location: "Augusta National Golf Club",
                        date: "NOV 05-08",
                        fee: 850,
                        isFeatured: false
                    )
                }
                .padding(.horizontal, 20)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("TU TEMPORADA")
                        .font(Theme.Typography.headline)
                        .kerning(1.2)
                        .foregroundColor(.secondary.opacity(0.7))
                        .padding(.horizontal, 25)
                    
                    HStack(spacing: 16) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("3ro")
                                .font(Font.system(size: 44, weight: .black)) // Special large size for ranking
                                .foregroundColor(Theme.primary)
                            
                            Text("Ranking Actual")
                                .font(Theme.Typography.button)
                                .foregroundColor(.secondary)
                            
                            Button("Ver Leaderboard") {
                            }
                            .font(Theme.Typography.button)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(Color.black)
                            .cornerRadius(15)
                            .padding(.top, 5)
                        }
                        .padding(25)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(32)
                        .shadow(color: .black.opacity(0.04), radius: 15, x: 0, y: 8)
                        
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue.opacity(0.1))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "sun.max.fill")
                                        .foregroundColor(.blue)
                                }
                                Spacer()
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Soleado")
                                    .font(Theme.Typography.title2)
                                Text("22°C • Vientos 8km/h")
                                    .font(Theme.Typography.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(25)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .cornerRadius(32)
                        .shadow(color: .black.opacity(0.04), radius: 15, x: 0, y: 8)
                    }
                    .padding(.horizontal, 20)
                }
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TU TEMPORADA")
                            .font(Theme.Typography.caption)
                            .foregroundColor(Theme.primary)
                        
                        Text("3ro")
                            .font(Font.system(size: 40, weight: .bold)) // Special large size
                        
                        Text("Ranking Actual")
                            .font(Theme.Typography.button)
                            .foregroundColor(.secondary)
                        
                        Button("Ver Leaderboard") {
                        }
                        .font(Theme.Typography.button)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Theme.primary)
                        .cornerRadius(12)
                        .padding(.top, 8)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.primary.opacity(0.1))
                    .cornerRadius(32)
                    
                    VStack(alignment: .leading, spacing: 20) {
                        HStack {
                            Image(systemName: "hand.point.up.left.fill")
                                .foregroundColor(.blue)
                                .padding(10)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Circle())
                            Spacer()
                            Text("Sab, Oct 12")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Soleado")
                                .font(.system(size: 24, weight: .bold))
                            Text("22°C • Viento 8km/h")
                                .font(Theme.Typography.caption)
                                .foregroundColor(.secondary)
                            Text("Condiciones perfectas")
                                .font(Theme.Typography.caption)
                                .foregroundColor(.blue)
                                .padding(.top, 4)
                        }
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .cornerRadius(32)
                    .shadow(color: Theme.Shadows.soft.color, radius: Theme.Shadows.soft.radius, x: Theme.Shadows.soft.x, y: Theme.Shadows.soft.y)
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(hex: "F8F9FA").ignoresSafeArea())
    }
}

#Preview {
    TournamentsView()
}
