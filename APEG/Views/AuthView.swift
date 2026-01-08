import SwiftUI
import AuthenticationServices

struct AuthView: View {
    @Environment(\.colorScheme) var colorScheme
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @State private var isRegistering = false
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var federationCode = ""
    @State private var idImage: UIImage?
    @State private var showImagePicker = false
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            // Background Layer
            LinearGradient(colors: [Theme.primary.opacity(0.8), .black], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 40) {
                    // Branding
                    VStack(spacing: 12) {
                        Image(systemName: "laurel.leading")
                            .font(.system(size: 70))
                            .foregroundColor(.white)
                        
                        Text("APEG")
                            .font(.system(size: 42, weight: .black, design: .serif))
                            .foregroundColor(.white)
                            .tracking(5)
                        
                        Text(isRegistering ? "ÚNETE AL CLUB" : "BIENVENIDO AL CLUB")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white.opacity(0.8))
                            .tracking(2)
                    }
                    .padding(.top, 60)
                    
                    // Auth Box
                    VStack(spacing: 24) {
                        if !errorMessage.isEmpty {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.horizontal)
                        }
                        
                        VStack(spacing: 16) {
                            if isRegistering {
                                CustomTextField(icon: "person", placeholder: "Nombre Completo", text: $name)
                                
                                CustomTextField(icon: "number", placeholder: "Código de Federación", text: $federationCode)
                                
                                Button(action: { showImagePicker = true }) {
                                    HStack {
                                        Image(systemName: "person.text.rectangle")
                                            .foregroundColor(.white.opacity(0.6))
                                            .frame(width: 20)
                                        
                                        if let image = idImage {
                                            Text("Cédula Cargada")
                                                .foregroundColor(.white)
                                            Spacer()
                                            Image(uiImage: image)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 40, height: 30)
                                                .cornerRadius(4)
                                        } else {
                                            Text("Foto de Cédula")
                                                .foregroundColor(.white.opacity(0.4))
                                            Spacer()
                                            Image(systemName: "camera.fill")
                                                .foregroundColor(.white.opacity(0.6))
                                        }
                                    }
                                    .padding()
                                    .background(Color.white.opacity(0.1))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                                    )
                                }
                            }
                            
                            CustomTextField(icon: "envelope", placeholder: "Correo Electrónico", text: $email)
                            
                            CustomTextField(icon: "lock", placeholder: "Contraseña", text: $password, isSecure: true)
                        }
                        
                        Button(action: {
                            handleAuth()
                        }) {
                            ZStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                } else {
                                    Text(isRegistering ? "Crear Cuenta" : "Iniciar Sesión")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(Color.white)
                            .cornerRadius(16)
                            .shadow(color: .white.opacity(0.2), radius: 10, x: 0, y: 5)
                        }
                        .disabled(isLoading)
                        
                        HStack {
                            Rectangle()
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 1)
                            Text("O")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.5))
                            Rectangle()
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 1)
                        }
                        
                        SignInWithAppleButton(.signIn) { request in
                            request.requestedScopes = [.fullName, .email]
                        } onCompletion: { result in
                            isLoggedIn = true
                        }
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 55)
                        .cornerRadius(16)
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                isRegistering.toggle()
                            }
                        }) {
                            HStack(spacing: 4) {
                                Text(isRegistering ? "¿Ya tienes cuenta?" : "¿No tienes cuenta?")
                                    .foregroundColor(.white.opacity(0.7))
                                Text(isRegistering ? "Inicia Sesión" : "Regístrate")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .font(.system(size: 14))
                        }
                    }
                    .padding(30)
                    .background(.ultraThinMaterial)
                    .cornerRadius(32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 32)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .padding(.horizontal, 20)
                    
                    Text("La excelencia está en cada detalle.")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.5))
                        .padding(.bottom, 40)
                }
            }
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $idImage)
        }
    }
    
    private func handleAuth() {
        isLoading = true
        errorMessage = ""
        
        if isRegistering {
            SupabaseManager.shared.signUp(email: email, password: password, fullName: name, federationCode: federationCode, idImage: idImage) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    switch result {
                    case .success:
                        isLoggedIn = true
                    case .failure(let error):
                        switch error {
                        case .authError(let msg): errorMessage = msg
                        default: errorMessage = "Error en el registro. Intenta de nuevo."
                        }
                    }
                }
            }
        } else {
            SupabaseManager.shared.signIn(email: email, password: password) { result in
                DispatchQueue.main.async {
                    isLoading = false
                    switch result {
                    case .success:
                        isLoggedIn = true
                    case .failure(let error):
                        switch error {
                        case .authError(let msg): errorMessage = msg
                        default: errorMessage = "Error al iniciar sesión. Intenta de nuevo."
                        }
                    }
                }
            }
        }
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.presentationMode) var presentationMode

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct CustomTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.6))
                .frame(width: 20)
            
            if isSecure {
                SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.4)))
            } else {
                TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.4)))
            }
        }
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .foregroundColor(.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}
