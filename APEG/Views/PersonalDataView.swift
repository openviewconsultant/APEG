import SwiftUI

struct PersonalDataView: View {
    @State private var profile: UserProfile?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = true
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        ZStack {
            Color(hex: "F8F9FA").ignoresSafeArea()
            
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .tint(Theme.primary)
            } else if let error = errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 40))
                        .foregroundColor(.red)
                    Text("Error al cargar datos")
                        .font(.headline)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    if let error = errorMessage, error == "Debes iniciar sesión nuevamente." {
                        Button("Iniciar Sesión") {
                            isLoggedIn = false
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Theme.primary)
                        .cornerRadius(12)
                        .padding(.top)
                    } else {
                        Button("Reintentar") {
                            loadData()
                        }
                        .foregroundColor(Theme.primary)
                        .padding(.top)
                    }
                }
            } else if let profile = profile {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header Image
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [Theme.primary, Theme.primary.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 120, height: 120)
                                
                                Text(getInitials(name: profile.fullName))
                                    .font(.system(size: 40, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .shadow(color: Theme.primary.opacity(0.3), radius: 15, x: 0, y: 8)
                            
                            Text(profile.fullName ?? "Sin Nombre")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .padding(.top, 20)
                        
                        // Data Cards
                        VStack(spacing: 16) {
                            DataRow(icon: "person.text.rectangle", title: "Nombre Completo", value: profile.fullName ?? "No especificado")
                            
                            DataRow(icon: "number.circle", title: "Código Federación", value: profile.federationCode ?? "No especificado")
                            
                            if let idUrl = profile.idPhotoUrl {
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Image(systemName: "doc.text.image")
                                            .foregroundColor(Theme.primary)
                                            .font(.system(size: 20))
                                        Text("Documento de Identidad")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    // In a real app, you'd use AsyncImage with the supabase storage URL
                                    // For now just showing a placeholder indicating it's there
                                    Text("Imagen cargada: \(idUrl)")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                        .padding()
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(16)
                                .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
                            }
                            
                            DataRow(icon: "calendar", title: "Actualizado", value: formatDate(profile.updatedAt))
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Datos Personales")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadData()
        }
    }
    
    private func loadData() {
        isLoading = true
        errorMessage = nil
        
        SupabaseManager.shared.fetchProfile { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let data):
                    self.profile = data
                case .failure(let error):
                    switch error {
                    case .authError:
                        self.errorMessage = "Debes iniciar sesión nuevamente."
                    default:
                        self.errorMessage = error.localizedDescription
                    }
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
    
    private func formatDate(_ dateString: String?) -> String {
        guard let dateString = dateString else { return "-" }
        // Simple string manipulation for display if full parsing isn't needed
        return String(dateString.prefix(10)) 
    }
}

struct DataRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Theme.primary.opacity(0.1))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(Theme.primary)
                    .font(.system(size: 18))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
