import SwiftUI

struct ProfileView: View {
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = true
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header / Profile Info
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [Theme.primary, Theme.primary.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 100, height: 100)
                        
                        Text("AB")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .shadow(color: Theme.primary.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    VStack(spacing: 4) {
                        Text("Alex Barragán")
                            .font(.system(size: 24, weight: .bold))
                        Text("Miembro Premium")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Theme.primary)
                    }
                }
                .padding(.top, 20)
                
                // Stats Grid
                HStack(spacing: 20) {
                    ProfileStatItem(title: "Handicap", value: "5.4")
                    ProfileStatItem(title: "Rondas", value: "128")
                    ProfileStatItem(title: "Torneos", value: "12")
                }
                .padding(.horizontal)
                
                // Menu Sections
                VStack(spacing: 20) {
                    ProfileMenuSection(title: "Mi Juego") {
                        ProfileMenuRow(icon: "figure.golf", title: "Estadísticas de Juego", color: .blue)
                        ProfileMenuRow(icon: "trophy", title: "Mis Torneos", color: .orange)
                    }
                    
                    ProfileMenuSection(title: "Cuenta") {
                         NavigationLink(destination: PersonalDataView()) {
                             ProfileMenuRowContent(icon: "person", title: "Datos Personales", color: .gray)
                         }
                         Divider()
                             .padding(.leading, 68)
                             .opacity(0.5)

                        ProfileMenuRow(icon: "creditcard", title: "Métodos de Pago", color: .purple)
                        ProfileMenuRow(icon: "bell", title: "Notificaciones", color: .red)
                    }
                    
                    // Logout Button
                    Button(action: {
                        isLoggedIn = false
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Cerrar Sesión")
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
            }
            .padding(.bottom, 120) // Space for tab bar
        }
            .background(Color(hex: "F8F9FA").ignoresSafeArea())
            .navigationBarHidden(true)
        }
    }
}

struct ProfileStatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 20, weight: .bold))
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
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
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.secondary)
                .padding(.horizontal, 24)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color.white)
            .cornerRadius(24)
            .padding(.horizontal)
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
    }
}

struct ProfileMenuRow: View {
    let icon: String
    let title: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            ProfileMenuRowContent(icon: icon, title: title, color: color)
        }
        Divider()
            .padding(.leading, 68)
            .opacity(0.5)
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
                        .frame(width: 36, height: 36)
                    Image(systemName: icon)
                        .foregroundColor(color)
                        .font(.system(size: 16, weight: .semibold))
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.gray.opacity(0.4))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
    }
}

#Preview {
    ProfileView()
}
