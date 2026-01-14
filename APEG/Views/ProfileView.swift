import SwiftUI

struct ProfileView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = true
    
    // State for user profile
    @State private var profile: UserProfile?
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            ZStack {
                Theme.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 32) {
                        // Header / Profile Info
                        if isLoading {
                        VStack(spacing: 16) {
                            Circle()
                                .fill(Color.white.opacity(0.05))
                                .frame(width: 100, height: 100)
                                .overlay(ProgressView())
                            
                            VStack(spacing: 8) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 150, height: 24)
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 100, height: 14)
                            }
                        }
                        .padding(.top, 40)
                    } else {
                        VStack(spacing: 20) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [Theme.primary, Theme.secondary], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 110, height: 110)
                                
                                Text(getInitials(name: profile?.fullName))
                                    .font(.system(size: 38, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .shadow(color: Theme.primary.opacity(0.3), radius: 20, x: 0, y: 10)
                            
                            VStack(spacing: 4) {
                                Text(profile?.fullName ?? "Usuario")
                                    .font(Theme.Typography.title2)
                                    .foregroundColor(.white)
                                
                                Text(profile?.isPremium == true ? "Socio de Oro" : "Socio")
                                    .font(Theme.Typography.subheadline)
                                    .foregroundColor(Theme.primary)
                                    .fontWeight(.bold)
                            }
                        }
                        .padding(.top, 40)
                    }
                    
                    // Stats Grid
                    HStack(spacing: 15) {
                        ProfileStatItem(title: "Handicap", value: "5.4")
                        ProfileStatItem(title: "Rondas", value: "128")
                        ProfileStatItem(title: "Torneos", value: "12")
                    }
                    .padding(.horizontal, 20)
                    
                    // Menu Sections
                    VStack(spacing: 30) {
                        ProfileMenuSection(title: "MI ACTIVIDAD") {
                            NavigationLink(destination: GameStatsView()) {
                                ProfileMenuRowContent(icon: "figure.golf", title: "Estadísticas", color: Theme.secondary)
                            }
                            
                            NavigationLink(destination: Text("Mis Torneos").font(.largeTitle)) {
                                ProfileMenuRowContent(icon: "trophy", title: "Mis Torneos", color: .orange)
                            }
                            
                            NavigationLink(destination: MyOrdersView()) {
                                ProfileMenuRowContent(icon: "bag", title: "Mis Pedidos", color: Theme.primary)
                            }
                        }
                        
                        ProfileMenuSection(title: "PREFERENCIAS") {
                            NavigationLink(destination: PersonalDataView()) {
                                ProfileMenuRowContent(icon: "person", title: "Datos Personales", color: .gray)
                            }
                            
                            NavigationLink(destination: Text("Métodos de Pago").font(.largeTitle)) {
                                ProfileMenuRowContent(icon: "creditcard", title: "Pagos", color: .purple)
                            }
                            
                            NavigationLink(destination: Text("Notificaciones").font(.largeTitle)) {
                                ProfileMenuRowContent(icon: "bell", title: "Notificaciones", color: .red)
                            }
                        }
                        
                        // Logout Button
                        Button(action: {
                            SupabaseManager.shared.signOut()
                            isLoggedIn = false
                        }) {
                            HStack {
                                Image(systemName: "power")
                                Text("Cerrar Sesión")
                                    .font(Theme.Typography.button)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(24)
                            .shadow(color: .red.opacity(0.3), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 10)
                    }
                }
                .padding(.bottom, 120)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadProfile()
        }
        }
    }
    
    private func loadProfile() {
        SupabaseManager.shared.fetchProfile { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let data):
                    self.profile = data
                case .failure(let error):
                    print("Error loading profile: \(error)")
                }
            }
        }
    }
    
    private func getInitials(name: String?) -> String {
        guard let name = name, !name.isEmpty else { return "??" }
        let parts = name.components(separatedBy: " ")
        if parts.count >= 2 {
            return "\(parts[0].prefix(1))\(parts[1].prefix(1))".uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }
}

struct ProfileStatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 6) {
            Text(value)
                .font(Theme.Typography.title3)
                .foregroundColor(.white)
            Text(title)
                .font(Theme.Typography.caption)
                .foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(Theme.cardBackground)
        .cornerRadius(24)
        .overlay(
            RoundedRectangle(cornerRadius: 24)
                .stroke(Color.white.opacity(0.05), lineWidth: 1)
        )
    }
}

struct ProfileMenuSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(Theme.Typography.caption)
                .kerning(1.5)
                .foregroundColor(.white.opacity(0.4))
                .padding(.horizontal, 30)
            
            VStack(spacing: 0) {
                content
            }
            .background(Theme.cardBackground)
            .cornerRadius(32)
            .overlay(
                RoundedRectangle(cornerRadius: 32)
                    .stroke(Color.white.opacity(0.05), lineWidth: 1)
            )
            .padding(.horizontal, 20)
        }
    }
}

struct ProfileMenuRowContent: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 16, weight: .bold))
            }
            
            Text(title)
                .font(Theme.Typography.body)
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white.opacity(0.2))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}
