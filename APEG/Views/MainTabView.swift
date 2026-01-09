import SwiftUI

// MARK: - Main Tab View

struct MainTabView: View {
    @State private var selectedTab = 0
    
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
        .ignoresSafeArea(.all, edges: .bottom)
    }
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            // Stats / Home -> House
            tabItem(index: 0, icon: "house.fill", label: "Inicio")
            
            Spacer()
            
            // Community / Tournaments -> Trophy
            tabItem(index: 1, icon: "trophy.fill", label: "Torneos")
            
            Spacer()
            
            // Central Action Button (Pop-out)
            centralButton
            
            Spacer()
            
            // Activity / Shop -> Shopping Bag
            tabItem(index: 3, icon: "bag.fill", label: "Tienda")
            
            Spacer()
            
            // Menu / Profile -> Person
            tabItem(index: 4, icon: "person.fill", label: "Perfil")
        }
        .padding(.horizontal, 30) // Icons spacing
        .frame(height: 72)
        .background(
            Capsule()
                .fill(Color(hex: "191919")) // Dark background close to black
                .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 24) // Float from screen edges
        .padding(.bottom, 20) // Float from bottom
        .ignoresSafeArea(.keyboard)
    }
    
    private var centralButton: some View {
        Button(action: {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                selectedTab = 2
            }
        }) {
            ZStack {
                Circle()
                    .fill(Color.white)
                    .frame(width: 58, height: 58)
                    .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 4)
                
                // 'S' Logo or distinctive Symbol - using Flag for Golf theme if prefered, but keeping S as brand for now.
                // Request said "icons allusive to themes". 
                // Center is GreenFees (Booking). A Flag is very golf. 
                Image(systemName: "flag.fill") 
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color(hex: "FF6B00")) // Orange Brand Color
            }
            .offset(y: -24) // Pop out effect
        }
    }
    
    private func tabItem(index: Int, icon: String, label: String) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = index
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .medium))
                    .foregroundColor(selectedTab == index ? Color(hex: "FF6B00") : .white.opacity(0.6))
            }
            .frame(width: 44, height: 44)
        }
    }
}

// Temporary ShopView if not moved to separate file yet
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
                        .font(.custom("Outfit-Bold", size: 34))
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
            .padding(.top, 50)
        }
        .background(Color(hex: "F8F9FA").ignoresSafeArea())
    }
}

#Preview {
    MainTabView()
}
