import SwiftUI

struct HomeView: View {
    @State private var showPlayView = false
    @State private var profile: UserProfile?
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var weatherManager: WeatherManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Header
                headerSection
                    .padding(.top, 20)
                
                // Main Weather/Play Card
                PlayActionCard(
                    temperature: weatherManager.temperature,
                    condition: weatherManager.condition,
                    symbol: weatherManager.symbol,
                    locationName: locationManager.cityName
                ) {
                    showPlayView = true
                }
                .padding(.horizontal, 20)
                
                // Quick Actions
                VStack(alignment: .leading, spacing: 20) {
                    Text("EXPLORAR")
                        .font(Theme.Typography.caption)
                        .kerning(1.5)
                        .foregroundColor(.white.opacity(0.4))
                        .padding(.horizontal, 25)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        QuickActionCard(title: "Reservar", icon: "calendar", color: Theme.primary) { }
                        QuickActionCard(title: "Torneos", icon: "trophy", color: .orange) { }
                        QuickActionCard(title: "Tienda", icon: "bag", color: Theme.secondary) { }
                    }
                    .padding(.horizontal, 20)
                }
                
                // Feature Banner
                adBanner
                
                // Tips Section
                VStack(alignment: .leading, spacing: 20) {
                    HStack {
                        Text("Pro Tips")
                            .font(Theme.Typography.title3)
                            .foregroundColor(.white)
                        Spacer()
                        Button("Ver Todo") {
                        }
                        .font(Theme.Typography.caption)
                        .foregroundColor(Theme.primary)
                    }
                    .padding(.horizontal, 25)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            TipCard(title: "Swing Tempo", time: "3 min", iconName: "gauge.with.needle", color: Theme.primary)
                            TipCard(title: "Mental Game", time: "5 min", iconName: "brain", color: .orange)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120) // Space for floating tab bar
                    }
                }
            }
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
            VStack(alignment: .leading, spacing: 4) {
                Text("HOLA,")
                    .font(Theme.Typography.caption)
                    .kerning(1.5)
                    .foregroundColor(.white.opacity(0.4))
                Text(profile?.fullName?.components(separatedBy: " ").first ?? "Edgar")
                    .font(Theme.Typography.title2)
                    .foregroundColor(.white)
            }
            
            Spacer()
            
            Button(action: {}) {
                Image(systemName: "bell")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(Theme.cardBackground)
                    .clipShape(Circle())
                    .overlay(
                        Circle().stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                    )
            }
        }
        .padding(.horizontal, 25)
    }
    
    private var adBanner: some View {
        TabView {
            PromoBannerCard(title: "Titleist TSi3", subtitle: "Precisión Pura", price: "$549", image: "clubs_bg")
                .padding(.horizontal, 20)
            PromoBannerCard(title: "FootJoy Pro", subtitle: "Comfort Total", price: "$189", image: "shoes_bg")
                .padding(.horizontal, 20)
        }
        .frame(height: 240)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
    }
}
