import SwiftUI

struct PersonalDataView: View {
    @State private var profile: UserProfile?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = true
    @Environment(\.presentationMode) var presentationMode
    
    // Editing State
    @State private var isEditing = false
    @State private var isSaving = false
    @State private var editFullName = ""
    @State private var editFederationCode = ""
    @State private var editEmail = ""
    
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
                            if isEditing {
                                EditableDataRow(icon: "person.text.rectangle", title: "Nombre Completo", text: $editFullName)
                                EditableDataRow(icon: "number.circle", title: "Código Federación", text: $editFederationCode)
                                EditableDataRow(icon: "envelope", title: "Correo Electrónico", text: $editEmail)
                            } else {
                                DataRow(icon: "person.text.rectangle", title: "Nombre Completo", value: profile.fullName ?? "No especificado")
                                DataRow(icon: "number.circle", title: "Código Federación", value: profile.federationCode ?? "No especificado")
                                DataRow(icon: "envelope", title: "Correo Electrónico", value: profile.email ?? "No especificado")
                            }
                            
                            if !isEditing {
                                if profile.idPhotoUrl != nil {
                                    VStack(alignment: .leading, spacing: 12) {
                                        HStack {
                                            Image(systemName: "doc.text.image")
                                                .foregroundColor(Theme.primary)
                                                .font(.system(size: 20))
                                            Text("Documento de Identidad")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        // Placeholder for full image loading
                                        Text("Imagen de identificación verificada")
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
                        }
                        .padding(.horizontal)
                        
                        // Buttons
                        if isEditing {
                            HStack(spacing: 20) {
                                Button(action: {
                                    withAnimation {
                                        isEditing = false
                                        // Reset fields
                                        editFullName = profile.fullName ?? ""
                                        editFederationCode = profile.federationCode ?? ""
                                        editEmail = profile.email ?? ""
                                    }
                                }) {
                                    Text("Cancelar")
                                        .fontWeight(.bold)
                                        .foregroundColor(.red)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.white)
                                        .cornerRadius(12)
                                        .shadow(color: .black.opacity(0.05), radius: 5)
                                }
                                
                                Button(action: saveData) {
                                    if isSaving {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Text("Guardar")
                                            .fontWeight(.bold)
                                    }
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Theme.primary)
                                .cornerRadius(12)
                                .shadow(color: Theme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                                .disabled(isSaving)
                            }
                            .padding(.horizontal)
                        } else {
                            Button(action: {
                                withAnimation {
                                    editFullName = profile.fullName ?? ""
                                    editFederationCode = profile.federationCode ?? ""
                                    editEmail = profile.email ?? ""
                                    isEditing = true
                                }
                            }) {
                                Text("Editar Datos")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Theme.secondary)
                                    .cornerRadius(12)
                                    .shadow(color: Theme.secondary.opacity(0.3), radius: 8, x: 0, y: 4)
                            }
                            .padding(.horizontal)
                        }
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
    
    private func saveData() {
        guard let currentProfile = profile else { return }
        isSaving = true
        
        SupabaseManager.shared.updateProfile(
            userId: currentProfile.id.uuidString,
            fullName: editFullName,
            federationCode: editFederationCode,
            email: editEmail
        ) { result in
            DispatchQueue.main.async {
                isSaving = false
                switch result {
                case .success:
                    isEditing = false
                    loadData() // Reload to confirm
                case .failure(let error):
                    // In a real app, show error alert
                    print("Error saving: \(error.localizedDescription)")
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
        return String(dateString.prefix(10))
    }
}

// MARK: - Components

struct DataRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Theme.primary.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .foregroundColor(Theme.primary)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                Text(value)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
    }
}

struct EditableDataRow: View {
    let icon: String
    let title: String
    @Binding var text: String
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Theme.primary.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: icon)
                    .foregroundColor(Theme.primary)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                
                TextField(title, text: $text)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 3)
    }
}
