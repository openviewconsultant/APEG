import SwiftUI

// MARK: - Main Tab View

struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var locationManager = LocationManager()
    @StateObject private var weatherManager = WeatherManager()
    
    init() {
        // Force the native TabBar to be invisible
        UITabBar.appearance().isHidden = true
        UITabBar.appearance().backgroundColor = .clear
        UITabBar.appearance().backgroundImage = UIImage()
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)
                    .toolbarBackground(.hidden, for: .tabBar)
                
                TournamentsView()
                    .tag(1)
                    .toolbarBackground(.hidden, for: .tabBar)
                
                // Central tab placeholder (Green Fees or Play)
                GreenFeesView()
                    .tag(2)
                    .toolbarBackground(.hidden, for: .tabBar)
                
                // Shop View
                ShopView()
                    .tag(3)
                    .toolbarBackground(.hidden, for: .tabBar)
                
                ProfileView()
                    .tag(4)
                    .toolbarBackground(.hidden, for: .tabBar)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 90) // Spacer for content scroll to clear floating bar
            }
            
            customTabBar
        }
        .environmentObject(locationManager)
        .environmentObject(weatherManager)
        .ignoresSafeArea(.all, edges: .bottom)
        .onAppear {
            if let location = locationManager.location {
                Task {
                    await weatherManager.fetchWeather(for: location)
                }
            }
        }
        .onChange(of: locationManager.location) { oldLocation, newLocation in
            if let location = newLocation {
                Task {
                    await weatherManager.fetchWeather(for: location)
                }
            }
        }
        .onChange(of: locationManager.isAuthorized) { oldAuth, isAuthorized in
            if isAuthorized, let location = locationManager.location {
                Task {
                    await weatherManager.fetchWeather(for: location)
                }
            }
        }
    }
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabItem(index: 0, icon: "house.fill", label: "Inicio")
            Spacer()
            tabItem(index: 1, icon: "trophy.fill", label: "Torneos")
            Spacer()
            
            // Push everything to the sides for central button
            Color.clear.frame(width: 65, height: 1)
            
            Spacer()
            tabItem(index: 3, icon: "bag.fill", label: "Tienda")
            Spacer()
            tabItem(index: 4, icon: "person.fill", label: "Perfil")
        }
        .padding(.horizontal, 25)
        .frame(height: 76)
        .background(
            ZStack {
                // Blur effect for premium feel
                BlurView(style: .systemUltraThinMaterialDark)
                    .clipShape(Capsule())
                
                Capsule()
                    .fill(Color(hex: "1A1A1A").opacity(0.85))
                    .overlay(
                        Capsule()
                            .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                    )
            }
        )
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 20)
        .padding(.bottom, 25)
        .overlay(
            centralButton
                .offset(y: -28)
        )
        .ignoresSafeArea(.keyboard)
    }
    
    private var centralButton: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedTab = 2
            }
        }) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 64, height: 64)
                    .shadow(color: Color(hex: "FF6B00").opacity(0.3), radius: 15, x: 0, y: 8)
                    .scaleEffect(selectedTab == 2 ? 1.1 : 1.0)
                
                Image(systemName: "flag.fill")
                    .font(.system(size: 26, weight: .black))
                    .foregroundColor(Color(hex: "FF6B00")) // Brand Orange
                    .symbolEffect(.bounce, value: selectedTab == 2)
                    .scaleEffect(selectedTab == 2 ? 1.1 : 1.0)
            }
        }
    }
    
    private func tabItem(index: Int, icon: String, label: String) -> some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = index
            }
        }) {
            VStack(spacing: 4) {
                ZStack {
                    if selectedTab == index {
                        Circle()
                            .fill(Color(hex: "FF6B00").opacity(0.15))
                            .frame(width: 36, height: 36)
                            .transition(.scale.combined(with: .opacity))
                    }
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: selectedTab == index ? .black : .medium))
                        .foregroundColor(selectedTab == index ? Color(hex: "FF6B00") : .white.opacity(0.5))
                        .symbolEffect(.bounce, value: selectedTab == index)
                        .scaleEffect(selectedTab == index ? 1.15 : 1.0)
                        .offset(y: selectedTab == index ? -2 : 0)
                }
                
                Text(label)
                    .font(.system(size: 10, weight: selectedTab == index ? .black : .bold))
                    .foregroundColor(selectedTab == index ? Color(hex: "FF6B00") : .white.opacity(0.5))
                    .scaleEffect(selectedTab == index ? 1.05 : 1.0)
            }
            .frame(width: 60, height: 48)
        }
    }
}

// Helper for blur effect (since ultraThinMaterial is SwiftUI 3.0+ but sometimes needs more control)
struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        return view
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

#Preview {
    MainTabView()
}
