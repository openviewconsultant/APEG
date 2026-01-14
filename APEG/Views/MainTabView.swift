import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @StateObject private var locationManager = LocationManager()
    @StateObject private var weatherManager = WeatherManager()
    
    init() {
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tag(0)
                TournamentsView()
                    .tag(1)
                GreenFeesView()
                    .tag(2)
                ShopView()
                    .tag(3)
                ProfileView()
                    .tag(4)
            }
            .background(Theme.background)
            
            customTabBar
        }
        .environmentObject(locationManager)
        .environmentObject(weatherManager)
        .preferredColorScheme(.dark)
        .ignoresSafeArea(.all, edges: .bottom)
    }
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabItem(index: 0, icon: "house.fill")
            tabItem(index: 1, icon: "trophy.fill")
            
            Spacer().frame(width: 80)
            
            tabItem(index: 3, icon: "bag.fill")
            tabItem(index: 4, icon: "person.fill")
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 12)
        .background {
            Capsule()
                .fill(Color(hex: "121212").opacity(0.85))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
                )
        }
        .background(BlurView(style: .systemThinMaterialDark).clipShape(Capsule()))
        .shadow(color: .black.opacity(0.4), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 20)
        .padding(.bottom, 25)
        .overlay {
            centralButton
                .offset(y: -32)
        }
    }
    
    private var centralButton: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                selectedTab = 2
            }
        }) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(colors: [Theme.primary, Theme.secondary], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 68, height: 68)
                    .shadow(color: Theme.primary.opacity(0.5), radius: 15, x: 0, y: 8)
                
                Image(systemName: "flag.fill")
                    .font(.system(size: 28, weight: .black))
                    .foregroundColor(.white)
            }
        }
    }
    
    private func tabItem(index: Int, icon: String) -> some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = index
            }
        }) {
            VStack(spacing: 0) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: selectedTab == index ? .black : .medium))
                    .foregroundColor(selectedTab == index ? .white : .white.opacity(0.4))
                
                if selectedTab == index {
                    Circle()
                        .fill(Theme.primary)
                        .frame(width: 4, height: 4)
                        .padding(.top, 4)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
    }
}

struct BlurView: UIViewRepresentable {
    var style: UIBlurEffect.Style
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}
