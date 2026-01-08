import SwiftUI

struct TournamentsView: View {
    @State private var selectedFilter = "Todos"
    let filters = ["Todos", "Pro", "Amateur", "Caridad"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                HStack {
                    Text("Torneos")
                        .font(.system(size: 34, weight: .bold))
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "magnifyingglass")
                            .font(.title3)
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                }
                .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(filters, id: \.self) { filter in
                            Button(action: { selectedFilter = filter }) {
                                Text(filter)
                                    .font(.system(size: 14, weight: .bold))
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(selectedFilter == filter ? Theme.primary : Color.black.opacity(0.05))
                                    .foregroundColor(selectedFilter == filter ? .white : .black)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                TournamentCard(
                    title: "The Coastal Open",
                    location: "Pebble Beach Golf Links",
                    date: "OCT 12-14",
                    fee: 450,
                    isFeatured: true
                )
                .padding(.horizontal)
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 12) {
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 180)
                            
                            Text("AMATEUR")
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.4))
                                .foregroundColor(.white)
                                .cornerRadius(6)
                                .padding(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Sunday Scramble")
                                .font(.system(size: 18, weight: .bold))
                            Text("Torrey Pines North")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text("$120")
                                    .font(.system(size: 16, weight: .bold))
                                Spacer()
                                Image(systemName: "plus")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.black)
                                    .clipShape(Circle())
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ZStack(alignment: .topLeading) {
                            RoundedRectangle(cornerRadius: 24)
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 180)
                            
                            Text("CARIDAD")
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.purple.opacity(0.4))
                                .foregroundColor(.white)
                                .cornerRadius(6)
                                .padding(12)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Kids Hope Cup")
                                .font(.system(size: 18, weight: .bold))
                            Text("TPC Sawgrass")
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text("$300")
                                    .font(.system(size: 16, weight: .bold))
                                Spacer()
                                Image(systemName: "plus")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                                    .padding(8)
                                    .background(Color.black)
                                    .clipShape(Circle())
                            }
                        }
                    }
                }
                .padding(.horizontal)
                
                // Simple list item for more tournaments
                HStack(spacing: 16) {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Theme.secondary.opacity(0.6))
                        .frame(width: 80, height: 80)
                        .overlay(Image(systemName: "figure.golf").foregroundColor(.white))
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Masters Qualifier")
                            .font(.system(size: 18, weight: .bold))
                        Text("Augusta National • Nov 05")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 12) {
                            Text("Stroke Play")
                                .font(.system(size: 10, weight: .bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.black.opacity(0.05))
                                .cornerRadius(6)
                            
                            HStack(spacing: 4) {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 8))
                                Text("Llenándose Rápido")
                            }
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(Theme.primary)
                        }
                    }
                    
                    Spacer()
                    
                    Text("$850")
                        .font(.system(size: 18, weight: .bold))
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(24)
                .padding(.horizontal)
                .shadow(color: Theme.Shadows.soft.color, radius: Theme.Shadows.soft.radius, x: Theme.Shadows.soft.x, y: Theme.Shadows.soft.y)
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("TU TEMPORADA")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(Theme.primary)
                        
                        Text("3ro")
                            .font(.system(size: 40, weight: .bold))
                        
                        Text("Ranking Actual")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        Button("Ver Leaderboard") {
                        }
                        .font(.system(size: 14, weight: .bold))
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
                                .font(.system(size: 12))
                                .foregroundColor(.secondary)
                            Text("Condiciones perfectas")
                                .font(.system(size: 12, weight: .bold))
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
