import SwiftUI

struct ShopView: View {
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Tienda Pro")
                        .font(.system(size: 34, weight: .bold))
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "cart")
                            .font(.title3)
                            .foregroundColor(.black)
                            .padding(10)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                    }
                }
                .padding(.horizontal)
                
                LazyVGrid(columns: columns, spacing: 16) {
                    ProductCard(title: "Titleist Pro V1", price: 54.99, imageName: "balls", brand: "Titleist")
                    ProductCard(title: "Stealth 2 Driver", price: 599.99, imageName: "driver", brand: "TaylorMade")
                    ProductCard(title: "FootJoy Traditions", price: 129.99, imageName: "shoes", brand: "FootJoy")
                    ProductCard(title: "Approach S62", price: 499.99, imageName: "watch", brand: "Garmin")
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .background(Color(hex: "F8F9FA").ignoresSafeArea())
    }
}

// MARK: - Main Tab View

struct MainTabView: View {
    @State private var selectedTab = 0
    @Namespace private var animation
    
    init() {
        // Force the native TabBar to be invisible and pass-through
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
                
                GreenFeesView()
                    .tag(2)
                    .toolbarBackground(.hidden, for: .tabBar)
                
                ShopView()
                    .tag(3)
                    .toolbarBackground(.hidden, for: .tabBar)
                
                ProfileView()
                    .tag(4)
                    .toolbarBackground(.hidden, for: .tabBar)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 80) // Spacer for content scroll
            }
            
            customTabBar
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            tabItem(index: 0, icon: "house.fill", label: "Inicio")
            tabItem(index: 1, icon: "trophy.fill", label: "Torneos")
            
            // Central Green Fee Button
            centralButton
            
            tabItem(index: 3, icon: "bag.fill", label: "Tienda")
            tabItem(index: 4, icon: "person.fill", label: "Perfil")
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 35, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                
                RoundedRectangle(cornerRadius: 35, style: .continuous)
                    .stroke(Color.white.opacity(0.5), lineWidth: 0.5)
            }
        )
        .padding(.horizontal, 16)
        .padding(.bottom, 24)
        .ignoresSafeArea(.keyboard)
    }
    
    private var centralButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedTab = 2
            }
        }) {
            VStack(spacing: 6) {
                ZStack {
                    if selectedTab == 2 {
                        Circle()
                            .fill(Theme.primary)
                            .frame(width: 60, height: 60)
                            .matchedGeometryEffect(id: "tab_glow", in: animation)
                            .shadow(color: Theme.primary.opacity(0.5), radius: 15, x: 0, y: 8)
                    } else {
                        Circle()
                            .fill(Color.black.opacity(0.05))
                            .frame(width: 54, height: 54)
                    }
                    
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(selectedTab == 2 ? .white : .primary.opacity(0.7))
                }
                .offset(y: selectedTab == 2 ? -25 : -10)
                
                Text("Reservar")
                    .font(.system(size: 10, weight: .black))
                    .foregroundColor(selectedTab == 2 ? Theme.primary : .primary.opacity(0.4))
                    .offset(y: selectedTab == 2 ? -15 : 0)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func tabItem(index: Int, icon: String, label: String) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = index
            }
        }) {
            VStack(spacing: 6) {
                ZStack {
                    if selectedTab == index {
                        Circle()
                            .fill(Theme.primary.opacity(0.1))
                            .frame(width: 40, height: 40)
                            .matchedGeometryEffect(id: "tab_indicator", in: animation)
                    }
                    
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .scaleEffect(selectedTab == index ? 1.1 : 1.0)
                }
                
                if selectedTab == index {
                    Text(label)
                        .font(.system(size: 10, weight: .bold))
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .foregroundColor(selectedTab == index ? Theme.primary : .primary.opacity(0.4))
            .frame(maxWidth: .infinity)
        }
    }
}

#Preview {
    MainTabView()
}
