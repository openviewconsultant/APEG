import SwiftUI

struct HomeView: View {
    @State private var showPlayView = false
    @State private var profile: UserProfile?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                
                // Main Play Card
                PlayActionCard() {
                    showPlayView = true
                }
                .padding(.horizontal)
                
                // Quick Actions Grid
                VStack(alignment: .leading, spacing: 16) {
                    Text("EXPLORAR")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        QuickActionCard(title: "Reservar", icon: "calendar.badge.plus", color: .green) { }
                        QuickActionCard(title: "Torneos", icon: "trophy", color: .orange) { }
                        QuickActionCard(title: "Tienda", icon: "bag", color: .blue) { }
                    }
                    .padding(.horizontal)
                }
                
                adBanner
                
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Pro Tips")
                            .font(.system(size: 20, weight: .bold))
                        Spacer()
                        Button("Ver Todo") {
                        }
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Theme.primary)
                    }
                    .padding(.horizontal)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            TipCard(title: "Swing Tempo", time: "3 min", iconName: "circle.hexagongrid.fill", color: Theme.primary)
                            TipCard(title: "Mental Game", time: "5 min", iconName: "brain.head.profile", color: .orange)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 120) // Space for tab bar
                    }
                }
            }
            .padding(.vertical)
        }
        .background(Color(hex: "F8F9FA").ignoresSafeArea())
        .fullScreenCover(isPresented: $showPlayView) {
            PlayView()
        }
        .onAppear {
            SupabaseManager.shared.fetchProfile { result in
                if case .success(let data) = result {
                    DispatchQueue.main.async {
                        self.profile = data
                    }
                }
            }
        }
    }
    
    private var headerSection: some View {
        HStack {
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay(Image(systemName: "person.fill").foregroundColor(.gray))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("BUENOS DÍAS")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.secondary)
                    // Display fetched first name or Default
                    Text(profile?.fullName?.components(separatedBy: " ").first ?? "Golfista")
                        .font(.system(size: 20, weight: .bold))
                }
            }
            
            Spacer()
            
            HStack(spacing: 16) {
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "sun.max.fill")
                            .foregroundColor(.orange)
                        Text("22°C")
                            .font(.system(size: 14, weight: .bold))
                    }
                    Text("Pebble Beach, CA")
                        .font(.system(size: 10))
                        .foregroundColor(.secondary)
                }
                
                Button(action: {}) {
                    Image(systemName: "bell.fill")
                        .foregroundColor(.black)
                        .padding(12)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var featuredEventCard: some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 32)
                .fill(LinearGradient(colors: [.black.opacity(0.6), .clear], startPoint: .bottom, endPoint: .top))
                .background(
                    Color.gray.opacity(0.3) // Placeholder for main image
                )
                .frame(height: 280)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    HStack(spacing: 4) {
                        Circle().fill(Theme.primary).frame(width: 6, height: 6)
                        Text("Registrado")
                            .font(.system(size: 12, weight: .bold))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.3))
                    .cornerRadius(20)
                    
                    Spacer()
                    
                    Image(systemName: "calendar")
                        .foregroundColor(.white)
                        .padding(10)
                        .background(Color.white.opacity(0.3))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("OCT 12-14")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Theme.primary)
                    
                    Text("Campeonato del Club")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                        Text("Pebble Beach Links")
                    }
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                }
            }
            .padding(24)
        }
        .padding(.horizontal)
        .shadow(color: Theme.Shadows.medium.color, radius: Theme.Shadows.medium.radius, x: Theme.Shadows.medium.x, y: Theme.Shadows.medium.y)
    }
    
    private var adBanner: some View {
        TabView {
            PromoBannerCard(
                tag: "Recién Llegado",
                title: "El Nuevo\nTitleist TSi3",
                price: "$549",
                imageName: "figure.golf",
                color: .black
            )
            .padding(.horizontal)
            
            PromoBannerCard(
                tag: "Oferta Especial",
                title: "TaylorMade\nStealth 2",
                price: "$599",
                imageName: "circle.hexagongrid.fill",
                color: Color(hex: "1A1A1A")
            )
            .padding(.horizontal)
            
            PromoBannerCard(
                tag: "Exclusivo",
                title: "Membresía\nPremium",
                price: "$199/año",
                imageName: "star.fill",
                color: Color(hex: "0D0D0D")
            )
            .padding(.horizontal)
        }
        .frame(height: 200)
        .tabViewStyle(.page(indexDisplayMode: .always))
    }
}

#Preview {
    HomeView()
}
