import SwiftUI

struct HomeView: View {
    @State private var showPlayView = false
    @State private var profile: UserProfile?
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var weatherManager: WeatherManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerSection
                
                // Main Play Card
                PlayActionCard(
                    temperature: weatherManager.temperature,
                    condition: weatherManager.condition,
                    symbol: weatherManager.symbol,
                    locationName: locationManager.cityName
                ) {
                    showPlayView = true
                }
                .padding(.horizontal, 20)
                
                // Quick Actions Grid
                VStack(alignment: .leading, spacing: 20) {
                    Text("EXPLORAR")
                        .font(Theme.Typography.headline)
                        .kerning(1.2)
                        .foregroundColor(.secondary.opacity(0.7))
                        .padding(.horizontal, 25)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        QuickActionCard(title: "Reservar", icon: "calendar.badge.plus", color: .green) { }
                        QuickActionCard(title: "Torneos", icon: "trophy.fill", color: .orange) { }
                        QuickActionCard(title: "Tienda", icon: "bag.fill", color: .blue) { }
                    }
                    .padding(.horizontal, 20)
                }
                
                adBanner
                
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Pro Tips")
                            .font(Theme.Typography.title3)
                        Spacer()
                        Button("Ver Todo") {
                        }
                        .font(Theme.Typography.button)
                        .foregroundColor(Theme.primary)
                    }
                    .padding(.horizontal, 25)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            TipCard(title: "Swing Tempo", time: "3 min", iconName: "circle.hexagongrid.fill", color: Theme.primary)
                            TipCard(title: "Mental Game", time: "5 min", iconName: "brain.head.profile", color: .orange)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120) // Space for tab bar
                    }
                }
            }
            .padding(.vertical, 10)
        }
        .background(Theme.background.ignoresSafeArea())
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
            HStack(spacing: 15) {
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 54, height: 54)
                    Image(systemName: "person.fill")
                        .font(.title2)
                        .foregroundColor(.gray.opacity(0.5))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("BUENOS DÍAS")
                        .font(Theme.Typography.subheadline)
                        .kerning(1.0)
                        .foregroundColor(.secondary.opacity(0.8))
                    Text(profile?.fullName?.components(separatedBy: " ").first ?? "Edgar")
                        .font(Theme.Typography.title2)
                        .foregroundColor(Theme.deepBlack)
                }
            }
            
            Spacer()
            
            HStack(spacing: 18) {
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 6) {
                        Image(systemName: weatherManager.symbol)
                            .font(.system(size: 18))
                            .foregroundColor(.orange)
                        Text(weatherManager.temperature)
                            .font(Theme.Typography.title2)
                            .foregroundColor(Theme.deepBlack)
                    }
                    Text(locationManager.cityName)
                        .font(Theme.Typography.caption)
                        .foregroundColor(.secondary)
                }
                
                Button(action: {}) {
                    Image(systemName: "bell.fill")
                        .font(.system(size: 20))
                        .foregroundColor(Theme.deepBlack)
                        .padding(14)
                        .background(Theme.pureWhite)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 10)
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
                            .font(Theme.Typography.caption)
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
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.primary)
                    
                    Text("Campeonato del Club")
                        .font(Theme.Typography.title1)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                        Text("Pebble Beach Links")
                    }
                    .font(Theme.Typography.body)
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
